#!./perl

BEGIN {
    chdir 't' if -d 't';
    unshift @INC,  '../lib';
    require './test.pl';
    skip_all("no cperl") unless is_cperl();
}

use strict;
use warnings;
use Config ();

plan tests => 39;

use feature 'switch';

$_ = "outside";
given("inside") { check_outside1() }
sub check_outside1 { is($_, "inside", "\$_ is not lexically scoped") }

{
    #no warnings 'experimental::lexical_topic';
    my $_ = "outside";
    $_ = "outside";
    given("inside") { check_outside2() }
    sub check_outside2 {
	is($_, "outside", "\$_ lexically scoped (lexical \$_)")
    }
}

# Make sure it still works with a lexical $_:
{
    #no warnings 'experimental::lexical_topic';
    my $_;
    my $test = "explicit comparison with lexical \$_";
    my $twenty_five = 25;
    my $ok;
    given($twenty_five) {
	when ($_ ge "40") { $ok = "forty" }
	when ($_ ge "30") { $ok = "thirty" }
	when ($_ ge "20") { $ok = "twenty" }
	when ($_ ge "10") { $ok = "ten" }
	default           { $ok = "default" }
    }
    is($ok, "twenty", $test);
}

# Optimized-away comparisons
{
    my $ok;
    given(23) {
	when (2 + 2 == 4) { $ok = 'y'; continue }
	when (2 + 2 == 5) { $ok = 'n' }
    }
    is($ok, 'y', "Optimized-away comparison");
}

{
    my $ok;
    given(23) {
        when (scalar 24) { $ok = 'n'; continue }
        default { $ok = 'y' }
    }
    is($ok,'y','scalar()');
}

# File tests
#  (How to be both thorough and portable? Pinch a few ideas
#  from t/op/filetest.t. We err on the side of portability for
#  the time being.)

{
    my ($ok_d, $ok_f, $ok_r);
    given("op") {
	when(-d)  {$ok_d = 1; continue}
	when(!-f) {$ok_f = 1; continue}
	when(-r)  {$ok_r = 1; continue}
    }
    ok($ok_d, "Filetest -d");
    ok($ok_f, "Filetest -f");
    ok($ok_r, "Filetest -r");
}

# Sub and method calls
sub notfoo {"bar"}
{
    my $ok = 0;
    given("foo") {
	when(notfoo()) {$ok = 1}
    }
    ok($ok, "Sub call acts as boolean")
}

{
    my $ok = 0;
    given("foo") {
	when(main->notfoo()) {$ok = 1}
    }
    ok($ok, "Class-method call acts as boolean")
}

{
    my $ok = 0;
    my $obj = bless [];
    given("foo") {
	when($obj->notfoo()) {$ok = 1}
    }
    ok($ok, "Object-method call acts as boolean")
}

# Other things that should not be smart matched
{
    my $ok = 0;
    given(12) {
        when( /(\d+)/ and ( 1 <= $1 and $1 <= 12 ) ) {
            $ok = 1;
        }
    }
    ok($ok, "bool not smartmatches");
}

{
    my $ok = 0;
    given(0) {
	when(eof(DATA)) {
	    $ok = 1;
	}
    }
    ok($ok, "eof() not smartmatched");
}

{
    my $ok = 0;
    my %foo = ("bar", 0);
    given(0) {
	when(exists $foo{bar}) {
	    $ok = 1;
	}
    }
    ok($ok, "exists() not smartmatched");
}

{
    my $ok = 0;
    given(0) {
	when(defined $ok) {
	    $ok = 1;
	}
    }
    ok($ok, "defined() not smartmatched");
}

{
    my $ok = 1;
    given("foo") {
	when((1 == 1) && "bar") {
	    $ok = 0;
	}
	when((1 == 1) && $_ eq "foo") {
	    $ok = 2;
	}
    }
    is($ok, 2, "((1 == 1) && \"bar\") not smartmatched");
}

{
    my $n = 0;
    for my $l (qw(a b c d)) {
	given ($l) {
	    when ($_ eq "b" .. $_ eq "c") { $n = 1 }
	    default { $n = 0 }
	}
	ok(($n xor $l =~ /[ad]/), 'when(E1..E2) evaluates in boolean context');
    }
}

{
    my $n = 0;
    for my $l (qw(a b c d)) {
	given ($l) {
	    when ($_ eq "b" ... $_ eq "c") { $n = 1 }
	    default { $n = 0 }
	}
	ok(($n xor $l =~ /[ad]/), 'when(E1...E2) evaluates in boolean context');
    }
}

{
    my $ok = 0;
    given("foo") {
	when((1 == $ok) || "foo") {
	    $ok = 1;
	}
    }
    ok($ok, '((1 == $ok) || "foo") smartmatched');
}

{
    my $ok = 0;
    given("foo") {
	when((1 == $ok || undef) // "foo") {
	    $ok = 1;
	}
    }
    ok($ok, '((1 == $ok || undef) // "foo") smartmatched');
}

# Make sure we aren't invoking the get-magic more than once

{ # A helper class to count the number of accesses.
    package FetchCounter;
    sub TIESCALAR {
	my ($class) = @_;
	bless {value => undef, count => 0}, $class;
    }
    sub STORE {
        my ($self, $val) = @_;
        $self->{count} = 0;
        $self->{value} = $val;
    }
    sub FETCH {
	my ($self) = @_;
	# Avoid pre/post increment here
	$self->{count} = 1 + $self->{count};
	$self->{value};
    }
    sub count {
	my ($self) = @_;
	$self->{count};
    }
}

my $f = tie my $v, "FetchCounter";

{
    my $first = 1;
    #no warnings 'experimental::lexical_topic';
    my $_;
    for (1, "two") {
	when ("two") {
	    is($first, 0, "Implicitly lexical loop: second");
	    eval {break};
	    like($@, qr/^Can't "break" in a loop topicalizer/,
	    	q{Can't "break" in a loop topicalizer});
	}
	when (1) {
	    is($first, 1, "Implicitly lexical loop: first");
	    $first = 0;
	    # Implicit break is okay
	}
    }
}

{
    my $first = 1;
    #no warnings 'experimental::lexical_topic';
    my $_;
    for $_ (1, "two") {
	when ("two") {
	    is($first, 0, "Implicitly lexical, explicit \$_: second");
	    eval {break};
	    like($@, qr/^Can't "break" in a loop topicalizer/,
	    	q{Can't "break" in a loop topicalizer});
	}
	when (1) {
	    is($first, 1, "Implicitly lexical, explicit \$_: first");
	    $first = 0;
	    # Implicit break is okay
	}
    }
}

{
    my $first = 1;
    #no warnings 'experimental::lexical_topic';
    for my $_ (1, "two") {
	when ("two") {
	    is($first, 0, "Lexical loop: second");
	    eval {break};
	    like($@, qr/^Can't "break" in a loop topicalizer/,
	    	q{Can't "break" in a loop topicalizer});
	}
	when (1) {
	    is($first, 1, "Lexical loop: first");
	    $first = 0;
	    # Implicit break is okay
	}
    }
}

# RT #94682:
# must ensure $_ is initialised and cleared at start/end of given block

sub f1 {
  #no warnings 'experimental::lexical_topic';
  my $_;
  given(3) {
    return sub { $_ } # close over lexical $_
  }
}
is(f1()->(), 3, 'closed over $_');

{
    package RT94682;

    my $d = 0;
    sub DESTROY { $d++ };

    sub f2 {
	my $_ = 5;
	given(bless [7]) {
            local $::TODO = '';
	    ::is($_->[0], 7, "is [7]");
	}
	::is($_, 5, "is 5");
	::is($d, 1, "DESTROY called once");
    }
    f2();
}
