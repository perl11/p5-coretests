#!./perl

BEGIN {
    unshift @INC, 'lib';
    require 'test.pl';
}

use strict;
use warnings;
use vars qw($fh @fh %fh);

eval 'opendir(NOSUCH, "no/such/directory");';
skip_all($@) if $@;
plan (tests => 13);

for my $i (1..2000) {
    local *OP;
    opendir(OP, "op") or die "can't opendir: $!";
    # should auto-closedir() here
}

is(opendir(OP, "op"), 1);
my @D = grep(/^[^\.].*\.t$/i, readdir(OP));
closedir(OP);

my $expect;
{
    while (<DATA>) {
	++$expect if m!^op/[^/]+!;
    }
}

my ($min, $max) = ($expect - 10, $expect + 10);
within(scalar @D, $expect, 10, 'counting op/*.t');

my @R = sort @D;
my @G = sort <op/*.t>;
if ($G[0] =~ m#.*\](\w+\.t)#i) {
    # grep is to convert filespecs returned from glob under VMS to format
    # identical to that returned by readdir
    @G = grep(s#.*\](\w+\.t).*#op/$1#i,<op/*.t>);
}
while (@R && @G && $G[0] eq 'op/'.$R[0]) {
	shift(@R);
	shift(@G);
}
is(scalar @R, 0, 'readdir results all accounted for');
is(scalar @G, 0, 'glob results all accounted for');

is(opendir($fh, "op"), 1);
is(ref $fh, 'GLOB');
is(opendir($fh[0], "op"), 1);
is(ref $fh[0], 'GLOB');
is(opendir($fh{abc}, "op"), 1);
is(ref $fh{abc}, 'GLOB');
isnt("$fh", "$fh[0]");
isnt("$fh", "$fh{abc}");

# See that perl does not segfault upon readdir($x="."); 
# http://rt.perl.org/rt3/Ticket/Display.html?id=68182
fresh_perl_like(<<'EOP', qr/^$|^Bad symbol for dirhandle at/, {}, 'RT #68182 - perlcc adjusted');
    my $x = ".";
    my @files = readdir($x);
EOP

#done_testing();

__DATA__
op/64bitint.t
op/alarm.t
op/anonsub.t
op/append.t
op/args.t
op/arith.t
op/array_base.t
op/array.t
op/assignwarn.t
op/attrhand.t
op/attrs.t
op/auto.t
op/avhv.t
op/bless.t
op/blocks.subtest.t
op/blocks.t
op/bop.t
op/caller.t
op/chars.t
op/chdir.t
op/chop.t
op/chr.t
op/closure.subtest.t
op/closure.t
op/cmp.t
op/concat2.subtest.t
op/concat2.t
op/concat.t
op/cond.t
op/context.t
op/cproto.t
op/crypt.t
op/dbm.subtest.t
op/dbm.t
op/defins.t
op/delete.t
op/die_except.t
op/die_exit.t
op/die_keeperr.t
op/die.t
op/die_unwind.t
op/dor.t
op/do.t
op/each_array.t
op/each.t
op/eval.subtest.t
op/eval.t
op/exec.t
op/exists_sub.t
op/exp.t
op/fh.t
op/filehandle.t
op/filetest_stack_ok.t
op/filetest.t
op/filetest_t.t
op/flip.t
op/fork.t
op/getpid.t
op/getppid.t
op/gmagic.t
op/goto.t
op/grent.t
op/grep.t
op/groups.t
op/gv.t
op/hashassign.t
op/hash.t
op/hashwarn.t
op/inccode.t
op/inccode-tie.t
op/incfilter.t
op/inc.t
op/index.subtest.t
op/index.t
op/index_thr.t
op/int.t
op/join.t
op/kill0.t
op/lc.t
op/lc_user.t
op/leaky-magic.subtest.t
op/leaky-magic.t
op/length.t
op/lex_assign.t
op/lex.t
op/lfs.t
op/list.t
op/localref.t
op/local.t
op/loopctl.t
op/lop.t
op/magic-27839.t
op/magic_phase.t
op/magic.subtest.t
op/magic.t
op/method.t
op/mkdir.t
op/mydef.t
op/my_stash.t
op/my.t
op/negate.t
op/not.t
op/numconvert.t
op/oct.t
op/ord.t
op/or.t
op/overload_integer.t
op/override.t
op/packagev.t
op/pack.t
op/pos.t
op/pow.t
op/print.subtest.t
op/print.t
op/protowarn.t
op/push.t
op/pwent.t
op/qq.t
op/qr.t
op/quotemeta.t
op/rand.t
op/range.t
op/readdir.subtest.t
op/readdir.t
op/readline.subtest.t
op/readline.t
op/read.t
op/recurse.t
op/ref.subtest.t
op/ref.t
op/repeat.t
op/require_errors.t
op/reset.t
op/reverse.t
op/runlevel.t
op/setpgrpstack.t
op/sigdispatch.t
op/sleep.t
op/smartkve.t
op/smartmatch.t
op/sort.t
op/splice.t
op/split.t
op/split_unicode.t
op/sprintf2.subtest.t
op/sprintf2.t
op/sprintf.t
op/srand.t
op/sselect.t
op/stash.subtest.t
op/stash.t
op/state.t
op/stat.t
op/study.t
op/studytied.t
op/sub_lval.subtest.t
op/sub_lval.t
op/sub.t
op/svleak.t
op/switch.t
op/symbolcache.t
op/sysio.t
op/taint.t
op/tiearray.t
op/tie_fetch_count.t
op/tiehandle.t
op/tie.t
op/time_loop.t
op/time.t
op/tr.subtest.t
op/tr.t
op/turkish.t
op/undef.t
op/universal.subtest.t
op/universal.t
op/unshift.t
op/upgrade.t
op/utf8cache.t
op/utf8decode.t
op/utf8magic.t
op/utfhash.t
op/utftaint.t
op/vec.t
op/ver.t
op/wantarray.t
op/warn.subtest.t
op/warn.t
op/while_readdir.t
op/write.t
op/yadayada.t
