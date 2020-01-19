use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/../../lib";
use Data::Dump qw(pp);
use Grep::Query qw(qgrep);

my @hl =
(
#	'a', 'bb', 'ccc'
	{ fee => 1, fie => [1,2,3], foo => { bar => 1}, brum => undef },
	{ fee => 2, fie => [4,5,6], foo => { bar => 2}, brum => undef },
	{ fee => 3, fie => [7,8,9], foo => { bar => 3}, brum => undef },
);

my @hl3 = qgrep('fie.size>=(2)', undef, @hl);
print pp(\@hl3), "\n";

__END__
my @deeplist =
	(
		{ fee => 1, fie => [ 1,2,3,4 ], foo => { a => 10 }, text => [ 'abc', 'xyz' ] },
		{ fee => 2, fie => [ 4,5,6,undef ], foo => { a => 20 }, text => [ 'plugh!', 'xyzzy' ]  },
		{ fee => 3333, fie => [ 7,8,9,10 ], foo => { a => 30 }, text => [ 'Tilo', 'Santino' ]  },
	);

my @hits2 = qgrep('fee.size(4)', undef, @deeplist);
print pp(\@hits2), "\n";

__END__
my @hl =
(
	{ fee => 1, fie => 2, foo => 3 },
	{ fee => 4, fie => 5, foo => 6 },
	{ fee => 7, fie => 8, foo => 9 },
);

my @hl3 = qgrep('true', undef, @hl);
print pp(\@hl3), "\n";
__END__

my $x = scalar(grep { ref($_) } (1,2,3,{},{}));
print "x=$x\n";

__END__
my @hl =
(
	{ fee => 1, fie => 2, foo => 3 },
	{ fee => 4, fie => 5, foo => 6 },
	{ fee => 7, fie => 8, foo => 9 },
);

my @hl3 = qgrep('true', undef, @hl);
print pp(\@hl3), "\n";


__END__
use Digest::Adler32;

my $digest = Digest::Adler32->new();

print fingerprint($digest, undef)->hexdigest(), "\n";
print fingerprint($digest, '')->hexdigest(), "\n";
print fingerprint($digest, [])->hexdigest(), "\n";
print fingerprint($digest, {})->hexdigest(), "\n";
print fingerprint($digest, [0])->hexdigest(), "\n";
print fingerprint($digest, [[]])->hexdigest(), "\n";
print fingerprint($digest, {fee=>0, fie=>0, foo=>0})->hexdigest(), "\n";
print fingerprint($digest, {foo=>0, fie=>0, fee=>0})->hexdigest(), "\n";

sub fingerprint
{
	my $digest = shift;
	my $obj = shift;

	my $type = ref($obj);
	$digest->add($type);
	if ($type eq 'ARRAY')
	{
		fingerprint($digest, $_) foreach (@$obj);
	}
	elsif ($type eq 'HASH')
	{
		fingerprint($digest, $obj->{$_}) foreach (sort(keys(%$obj)));
	}
	else
	{
		$digest->add($digest->digest());
	}
	
	return $digest;	
}

__END__
print $digest->hexdigest(), "\n";
$digest->reset();
$digest->add($digest->hexdigest());
print $digest->hexdigest(), "\n";



__END__
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