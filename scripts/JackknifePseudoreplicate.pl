#! /usr/bin/perl
use strict;
use warnings;

########################################################
## USAGE
##
my $USAGE =<<USAGE;

	Usage: JackknifePseudoreplicate.pl sequences.fasta

		sequences.fasta:  	Fasta file with genomes to split
USAGE
#
######################################################

#print "@ARGV";
if($#ARGV!=0){
	print "$USAGE\n";
    exit;
}

my $fasta = $ARGV[0]; # fasta file
my $reps = $ARGV[1]; # numbers of pseudoreplicates

# Extract sequences from fasta file
open(FNA, $fasta) or die "Couldn't open $fasta.\n";

my %seqs;
my $seq_id='';
my $seq_count = 0;

while (my $line = <FNA>){
        chomp $line; 
	if ($line =~ m/^>(.+)/){
		$seq_count++;
		$seq_id = $1;
	}else{
		$seqs{$seq_id} .= $line;
	}
}
close FNA;
print "There are $seq_count sequences in FASTA file.\n";

# Run pseudoreplicate
my $t = localtime();
print "[$t] Generating pseudoreplicate.\n";

my @path = split /\//, $fasta;
my @file_name = split /\./, $path[-1];
my $prefix = $file_name[0];
my $out = $prefix . "_pseudorep.fa";
open(OUT, '>', $out) or die "Can't open $out.\n";

foreach my $id (keys %seqs){
	my $seq = $seqs{$id};
   	my $L = length($seq);
	my $N = int((($L * 0.4) / 10000) + 0.5);
	print "\t-$id is $L bp long and will be reduced $N times.\n";
	for(my $i = 1; $i < ($N + 1); $i++){
		my $ceiling = length($seq) - 10000;
		my $start = int(rand($ceiling));
		my $del = substr $seq, $start, 10000, "";
		print "\t\t\t[$i/$N] Current lenght of $id is $ceiling\r"
	}
	my $lf = (length($seq) / $L) * 100;
	print "\n\t-Length fraction of $id: $lf %\n";
	print OUT ">$id\n$seq\n";
}
close OUT;

