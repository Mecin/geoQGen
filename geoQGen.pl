#!/usr/bin/perl -w

use strict;
use warnings;

use Geo::Geocalc;
#use Geo::Geocalc qw(&getDistance);

# auto space
$, = " ";

# auto line breaker
$\ = "\n";

my $lat1 = 51.715283;
my $lng1 = 20.344549;

my $lat2 = 40.417875;
my $lng2 = -3.710205;

my $R = 6378.41;

my $outputKmlFilename = "result.kml";
my @coordinates;

push @coordinates, $lat1, $lng1, $lat2, $lng2;

print ">> getDistance method check";
print "Distance between Cielądz and Madrid is " . &Geo::Geocalc::getDistance($lat1,$lng1,$lat2,$lng2,$R) . " km.";

print ">> generateKMLPlacemarks method check";
&Geo::Geocalc::generateKMLPlacemarks($outputKmlFilename, @coordinates);

#open(FILE, ">$outputKmlFilename") || die "Can not open file!";
#print FILE 
#close FILE;

