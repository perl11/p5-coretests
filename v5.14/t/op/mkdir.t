#!./perl -w

BEGIN {
    unshift @INC, 't/CORE/lib';
    require 't/CORE/test.pl';
}

plan tests => 22;

unless (eval {
    require File::Path;
    File::Path::rmtree('blurfl');
    1
}) {
    diag("$0 may fail if its temporary directory remains from a previous run");
    diag("Attempted to load File::Path to delete directory t/blurfl - error was\n$@");
    diag("\nIf you have problems, please manually delete t/blurfl");
}    

# tests 3 and 7 rather naughtily expect English error messages
$ENV{'LC_ALL'} = 'C';
$ENV{LANGUAGE} = 'C'; # GNU locale extension

ok(mkdir('blurfl',0777), 'mkdir blurfl');
ok(!mkdir('blurfl',0777), 'mkdir blurfl a second time');
ok($!{EEXIST} || $! =~ /cannot move|exist|denied|unknown/i, '$!{EEXIST} or $!');
ok(-d 'blurfl');
ok(rmdir('blurfl'));
ok(!rmdir('blurfl'));
ok($!{ENOENT} || $! =~ /cannot find|such|exist|not found|not a directory|unknown/i);
ok(mkdir('blurfl'));
ok(rmdir('blurfl'));

# trailing slashes will be removed before the system call to mkdir
ok(mkdir('blurfl///'), 'mkdir blurfl///');
ok(-d 'blurfl', '-d blurfl');
ok(rmdir('blurfl///'), 'rmdir blurfl///');
ok(!-d 'blurfl', '!-d blurfl');

# test default argument

$_ = 'blurfl';
ok(mkdir);
ok(-d);
ok(rmdir);
ok(!-d);
$_ = 'lfrulb';

{
    my $_ = 'blurfl';
    ok(mkdir);
    ok(-d);
    ok(-d 'blurfl');
    ok(!-d 'lfrulb');
    ok(rmdir);
}
