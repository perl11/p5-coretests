#!perl -w

BEGIN { require 'test.pl' }

plan(20);

sub End::DESTROY { $_[0]->() }

sub end(&) {
    my($c) = @_;
    return bless(sub { $c->() }, "End");
}

foreach my $inx ("", "aabbcc\n", [qw(aa bb cc)]) {
    foreach my $outx ("", "xxyyzz\n", [qw(xx yy zz)]) {
	my $warn = "";
	local $SIG{__WARN__} = sub { $warn .= $_[0] };
	{
	    $@ = $outx;
	    my $e = end { die $inx if $inx };
	}
	ok ref($@) eq ref($outx) && $@ eq $outx;
	$warn =~ s/ at [^\n]*\n\z//;
	is $warn, $inx ? "\t(in cleanup) $inx" : "";
    }
}

{
    no warnings "misc";
    my $warn = "";
    local $SIG{__WARN__} = sub { $warn .= $_[0] };
    { my $e = end { die "aa\n"; }; }
    is $warn, "";
}

{
    my $warn = "";
    local $SIG{__WARN__} = sub { $warn .= $_[0] };
    { my $e = end { no warnings "misc"; die "aa\n"; }; }
    is $warn, "\t(in cleanup) aa\n";
}

1;
