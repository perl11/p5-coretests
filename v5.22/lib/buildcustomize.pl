#!perl

#   !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
#   This file is generated by write_buildcustomize.pl.
#   Any changes made here will be lost!

# We are miniperl, building extensions
# Replace the first entry of @INC ("lib") with the list of
# directories we need.

splice(@INC, 0, 1, q /root/rpmbuild/BUILD/perl-5.22.0/cpan/AutoLoader/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/Carp/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/PathTools ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/PathTools/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/ExtUtils-Command/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/ExtUtils-Install/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/ExtUtils-MakeMaker/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/ExtUtils-Manifest/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/File-Path/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/ext/re ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/Term-ReadLine/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/Exporter/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/ext/File-Find/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/cpan/Text-Tabs/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/dist/constant/lib ,
        q /root/rpmbuild/BUILD/perl-5.22.0/lib );
$^O = 'linux';
__END__
