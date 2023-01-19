#! /usr/bin/perl
use strict;
use warnings;
use List::MoreUtils qw(uniq);

########################################################
## USAGE
##
my $USAGE =<<USAGE;

	Usage: FullLengthCDS.pl CDS.fasta <prefix>

		CDS.fasta:	Fasta file containing complete and incomplete CDS
		<prefix>:	Prefix to use for output
USAGE
#
######################################################

#print "@ARGV";
if($#ARGV!=1){
	print "$USAGE\n";
    exit;
}

my $cds = $ARGV[0]; # fasta file
my $prefix = $ARGV[1]; # prefix

# Extract sequences from fasta files
my %CDS = extract_sequences($cds);

# Check completeness in each sequences
my $out = "${prefix}.full_length_CDS.tsv";
open(OUT, '>', $out) or die "Can't open $out.\n";
print OUT "#Sequence_ID\tSequence_length\tIn_frame\tStart_codon\tStop_codon\n";

foreach my $id (keys %CDS){
	chomp $id;
	print OUT "$id\t";
	my $seq_len = length($CDS{$id});
	print OUT "$seq_len\t";
	if ($seq_len % 3 == 0){
		print OUT "y\t";
	}else{
		print OUT "n\t"
	}
	if ($CDS{$id} =~ m/^ATG/){
		print OUT "y\t";
	}else{
		print OUT "n\t";
	}
	if ($CDS{$id} =~ m/TAA$/ || $CDS{$id} =~ m/TAG$/ || $CDS{$id} =~ m/TGA$/){
		print OUT "y\n";
	}else{
		print OUT "n\n";
	}
}
close OUT;

# Subroutines
sub extract_sequences{
	my ($file) = @_;
	open(my $fh, $file) or die "Couldn't open $file.\n";
	binmode($fh);
	my %seqs;
	my $seq_id='';
	my $seq_count = 0;
	while (my $line = <$fh>){
		chomp $line;
		if ($line =~ m/^>(.*)$/){
			$seq_count++;
			my @items = split /\s/, $1;
			$seq_id = $items[0];
			#print "This is seq_id: $seq_id\n";
		}else{
			$seqs{$seq_id} .= $line;
		}
	}
	return %seqs;
	print "There are $seq_count sequences in $file\n";
	close $fh;
}

exit 0;
