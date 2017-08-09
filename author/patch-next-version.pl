use 5.010_001;

use strict;
use warnings;

$| = 1;

my $msgfile = $ARGV[0] || '';
die("Missing message file\n") unless -f $msgfile;
my $msgfile2 = "$msgfile.tmp.$$";

my $toplevel = qx(git rev-parse --show-toplevel 2>&1);
die("Failed to get toplevel:\n$toplevel") if $?;
chomp($toplevel);
chdir($toplevel) or die("Failed to chdir to $toplevel: $!\n");

my %files = 
	(
		'README.md' => [1],
		'lib/Grep/Query.pm' => [8, 190],
	);

foreach my $fn (keys(%files))
{
	die("Failed to find '$fn' in '$toplevel'\n") unless -f "$toplevel/$fn";
}

# verify we're clean
#
my @status = qx(git status --porcelain --ignored 2>&1);
die("Tree not clean:\n@status") if (@status || $?);
 
# find the current branch:
#
my @br = qx(git symbolic-ref --short HEAD 2>&1);
die("Failed symbref:\n@br") if $?;
chomp(@br);
die("No current branch found") unless @br;
die("Invalid branch: '$br[0]'") unless $br[0] =~ /^(\d+)\.(?:(\d\d\d)_)?xxx$/;

my $mj = $1;
my $min = $2;
my $isdev = defined($min) ? 1 : 0;

system("git fetch --all -q 2>&1");
die("Failed fetch") if $?;

my @tags = qx(git tag -l 2>&1);
die("Failed tags:\n@tags") if $?;
chomp(@tags);

my $tagfilter = $isdev ? qr/^v(${mj}\.${min}_(\d\d\d))$/ : qr/^v(${mj}\.(\d\d\d))$/;
@tags = sort(grep(/$tagfilter/, @tags));  
my $lastTag = $tags[-1];
die("???") unless $lastTag =~ /$tagfilter/;
my $currentVersion = sprintf("${mj}.%s%03d", ($isdev ? "${min}_" : ''), $2);
my $currentVersionRE = qr(\Q$currentVersion\E);
my $nextVersion = sprintf("${mj}.%s%03d", ($isdev ? "${min}_" : ''), $2 + 1);
my $nextTag = "v$nextVersion";

foreach my $fn (keys(%files))
{
	my $lines = $files{$fn};
	$fn = "$toplevel/$fn";
	foreach my $line (@$lines)
	{
		my $idx = $line - 1;
		my @contents = readAll($fn);
		die("The file '$fn' does not have the current version '$currentVersion' in line $line\n") unless $contents[$idx] =~ /$currentVersionRE/;
		$contents[$idx] =~ s/$currentVersionRE/$nextVersion/;
		writeAll($fn, @contents);
	}
}

my @msg = readAll($msgfile);
my $subj = "Release $nextVersion";
writeAll($msgfile2, $subj, "", @msg);

my @tm = localtime();
my $today = sprintf("%d-%02d-%02d\n", $tm[5] += 1900, $tm[4] + 1, $tm[3]);

my @changes = readAll('Changes');
foreach (@msg)
{
	$_ = "\t$_" if $_;
}
splice(@changes, 2, 0, "$nextVersion\t$today", @msg, "");
writeAll('Changes', @changes);

my @mk = qx(perl Makefile.PL 2>&1);
die("Failed creating makefile:\n@mk") if $?;

my $mkcfg = qx(perl -V:make 2>&1);
die("Failed finding make config:\n$mkcfg") if $?;
die("Unexpected mkcfg: '$mkcfg'\n") unless $mkcfg =~ /^make='([^']+)'/; #'
my $mkcmd = $1;

my $expectedDist = "Grep-Query-$nextVersion.tar.gz";
system("$mkcmd dist 2>&1");
die("Failed making dist '$expectedDist'\n") if ($? || !-f $expectedDist);

print "The current branch is '$br[0]' with next version = '$nextVersion'\n";
print "Ready to commit => tag => push => upload? ";
my $a = <STDIN>;
chomp($a);
if (lc($a) eq 'yes')
{
	print "Committing, tagging, pushing and uploading...\n";
	
	system("git commit -a -F $msgfile2 2>&1");
	die("Failed commit") if $?;

	system("git tag $nextTag 2>&1");
	die("Failed tag\n") if $?;
	
	system("git push origin $br[0] $nextTag 2>&1");
	die("Failed push\n") if $?;
	
	system("cpan-upload -v --user knth $expectedDist");
	die("Failed upload\n") if $?;
}
else
{
	my @realclean = qx($mkcmd realclean 2>&1);
	die("Failed making realclean:\n@realclean") if $?;

	print "Reverting!\n";
	my @reset = qx(git reset --hard 2>&1);
	die("Failed reset:\n@reset") if $?;
}

unlink($msgfile2);

print "END\n";

sub readAll
{
	my $fn = shift;
	
	open(my $fh, '<', $fn) or die("Failed to open '$fn': $!\n");
	binmode($fh);
	local $\ = undef;
	my @c = <$fh>;
	close($fh);
	chomp(@c);
	
	return @c;
}

sub writeAll
{
	my $fn = shift;
	my @c = @_;

	open(my $fh, '>', $fn) or die("Failed to open '$fn': $!\n");
	binmode($fh);
	print $fh "$_\n" foreach (@c);
	close($fh);
}
