use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Data::Dump qw(pp);
use Grep::Query qw(qgrep);

my @hl =
(
	{ fee => 1, fie => 2, foo => 3 },
	{ fee => 4, fie => 5, foo => 6 },
	{ fee => 7, fie => 8, foo => 9 },
);

#my @hl3 = qgrep('true', undef, @hl);
#print pp(\@hl3), "\n";
#
#my @hits = qgrep('fee.>(3)', undef, @hl);
#print pp(\@hits), "\n";

my @deeplist =
	(
		{ fee => 1, fie => [ 1,2,3 ], foo => { a => 10 }, text => [ 'abc', 'xyz' ] },
		{ fee => 2, fie => [ 4,5,6 ], foo => { a => 20 }, text => [ 'plugh!', 'xyzzy' ]  },
		{ fee => 3, fie => [ 7,8,9 ], foo => { a => 30 }, text => [ 'Tilo', 'Santino' ]  },
	);

#my @hits2 = qgrep('foo->a.>=(11) ', undef, @deeplist);
#my @hits2 = qgrep('fie->[2].<(5) or foo->a.>=(21)', undef, @deeplist);
#my @hits2 = qgrep('fee.==(1)', undef, @deeplist);
my @hits2 = qgrep('text->[0].eq(plugh!)', undef, @deeplist);
print pp(\@hits2), "\n";

__END__

#my @list = qw(fee fie foo);
#
#my @hits = qgrep('regexp(e)', @list);
#print "HITS
#

#my @hashlist =
#	(
#		{ fee => 1, fie => 2, foo => 3 },
#		{ fee => 4, fie => 5, foo => 6 },
#		{ fee => 7, fie => 8, foo => 9 },
#	);
#
#my @hits = qgrep('fee.>(3)', undef, @hashlist);
#print pp(\@hits), "\n";

my @deeplist =
	(
		{ fee => 1, fie => 2, foo => { a => 10 } },
	);

my @hits = qgrep('foo->a.>(3)', undef, @deeplist);
print pp(\@hits), "\n";