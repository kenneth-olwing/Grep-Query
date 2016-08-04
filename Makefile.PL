use strict;
use warnings;

use 5.010;
use ExtUtils::MakeMaker '7.12'; # when TEST/CONFIGURE_REQUIRES is understood...

WriteMakefile(
	NAME             => 'Grep::Query',
	AUTHOR           => q{Kenneth Olwing <knth@cpan.org>},
	VERSION_FROM     => 'lib/Grep/Query.pm',
	ABSTRACT_FROM    => 'lib/Grep/Query.pm',
	LICENSE          => 'artistic_2',
	EXE_FILES        => [ 'script/qgrep' ],
	# initial dev was made using: ActiveState: This is perl 5, version 20, subversion 1 (v5.20.1) built for MSWin32-x86-multi-thread-64int
	# we use named capture groups...
	#
	MIN_PERL_VERSION => 5.010,
	CONFIGURE_REQUIRES =>
		{
			'ExtUtils::MakeMaker' => '7.12', 
		},
	TEST_REQUIRES =>
		{
			'Test::More' => 0, # initial dev used: 1.001003
			'Test::Differences' => 0, # initial dev used: 0.62 
			'Test::Exception' => 0, # initial dev used: 0.32
		},
	PREREQ_PM =>
		{
			'Parse::RecDescent'	=> 0, # initial dev used: 1.967013
			'IO::Scalar' => 0, # initial dev used: 2.111
		},
	META_MERGE =>
		{
			'meta-spec' =>
				{
					version => 2,
				},
			resources =>
				{
					repository =>
						{
							type => 'git',
							url => 'https://github.com/kenneth-olwing/Grep-Query.git',
							web => 'https://github.com/kenneth-olwing/Grep-Query'
						}
				}
		},
	dist  =>
		{
			$^O eq 'MSWin32' ? (TARFLAGS => '--mode=755 -cvf') : (),
			COMPRESS => 'gzip -9f',
			SUFFIX => 'gz',
			DIST_DEFAULT => 'xtest test tardist'
		},
	clean => { FILES => 'Grep-Query-* *.tmp' },
);

package MY;

sub postamble
{
	return <<'MAKE_FRAG';

# analogous to 'make test', to  run tests under xt using 'make xtest'
#
.PHONY : xtest
xtest ::
	$(NOECHO) prove -lr xt 

MAKE_FRAG
}

