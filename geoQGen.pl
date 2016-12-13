#!/usr/bin/perl -w

use strict;
use warnings;

#use Geo::Geocalc;
use Geo::Geocalc qw(&getDistance);

# auto space
$, = " ";

# auto line breaker
$\ = "\n";

my $lat1 = 51.715283;
my $lng1 = 20.344549;

my $lat2 = 40.417875;
my $lng2 = -3.710205;

my $R = 6378.41;

print "Hello world $0!";
print ">> getDistance";
print "Distance between Cielądz and Madrid is " . &Geo::Geocalc::getDistance($lat1,$lng1,$lat2,$lng2,$R) . " km.";


