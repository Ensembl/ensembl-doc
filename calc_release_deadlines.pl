#!/usr/local/bin/perl -w

=head1 NAME

calc_release_deadlines.pl - work out dates for an Ensembl release

=head1 SYNOPSIS

calc_release_deadlines.pl --release "2004-05-01"

Options:
  --help, --release

=head1 OPTIONS

B<-h,--help>
  Prints usage message and exits.

B<--release>
  REQUIRED.  Specifies the date Ensembl is due to release, in EU style.
  e.g. "22/07/2004", "22-07-2004", "22 July 2004"

=head1 DESCRIPTION

B<This program:>

Calculates deadlines for an Ensembl release.
Counts back from the given release date, accounting for holidays, to allow
each phase of the process the allotted number of working days.

=cut

use strict;
use Date::Calendar;
use Date::Calc qw(Decode_Date_EU);
use Date::Calc::Object qw(:all);
use Date::Calendar::Profiles qw($Profiles);
use Getopt::Long;
use Pod::Usage;

my ($help,$rdate);
&GetOptions( 'release:s' => \$rdate,
             'help|h'	 => \$help,
           );

pod2usage(-verbose => 2) if $help;
pod2usage(-verbose => 2) unless $rdate;

########################
# Allotted Working Days
########################

my @days = (#	{   phase   =>	'ID-mapping',
	    #	    days    =>	3,
	    #	},
		{   phase   => 'Genebuild handover to core/compara',
		    days    =>	10,
		},
		{   phase   => 'Core/Compara handover to web/mart',
		    days    =>	5,
		},
		{   phase   => 'Mart handover to web',
		    days    =>	2,
		},
	    );

Date::Calc->date_format(2);
my $cal = Date::Calendar->new( $Profiles->{'GB'} );
my $releasedate;
eval {
    $releasedate = Date::Calc->new(Decode_Date_EU($rdate));
};

die "$rdate is not a parsable date\n" unless $releasedate;
my $lastphase = "Release";
my $lastdate = $cal->add_delta_workdays($releasedate,-1);
my $runtot = 0;

print "Release is due on $releasedate\n";
for (my $n = $#days; $n >=0; $n--){
    my $phase = $days[$n]->{phase};
    my $diff = $days[$n]->{days};
    my $date = $cal->add_delta_workdays($lastdate,-$diff);
    print "$date: $phase\n";
    print "\t($diff wd before $lastphase)\n";
    $lastdate = $date;
    $lastphase= $phase;

}

