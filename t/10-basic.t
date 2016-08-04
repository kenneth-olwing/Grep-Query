use strict;
use warnings;

use Grep::Query qw(qgrep);
use Grep::Query::FieldAccessor;

use Test::More tests => 8;

is(scalar(qgrep('REGEXP(.*)')), 0, "query empty plain set (non-OO)");

my $gq1 = Grep::Query->new('REGEXP(.*)');
is(scalar($gq1->qgrep()), 0, "query empty plain set");

my $gq2 = Grep::Query->new('field1.REGEXP(.*)');
is(scalar($gq2->qgrep(undef)), 0, "query empty fielded set");

my $fa = Grep::Query::FieldAccessor->new({ field1 => sub { die("never executed") } });
is(scalar($gq2->qgrep($fa)), 0, "query empty fielded set with explicit field accessor");

ok(defined(Grep::Query->new('REGEXP(.*) AND EQ(42) OR NE(15) AND GT(9) OR GE(98) AND LT(65) OR LT(32)')), "UPPERCASING");

ok(defined(Grep::Query->new('regexp(.*) and eq(42) or ne(15) and gt(9) or ge(98) and lt(65) or lt(32)')), "LOWERCASING");

ok(defined(Grep::Query->new('==(42) or !=(15) and >(9) or >=(98) and <(65) or <=(32)')), "NUMERICAL");

ok(defined(Grep::Query->new('foo.==(42) OR foo.==(68)')), "one field multiple times");
