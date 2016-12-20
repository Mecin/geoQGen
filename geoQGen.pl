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
print "Distance between Cielądz and Madrid is " . &Geo::Geocalc::getDistance($lat1, $lng1, $lat2, $lng2, $R) . " km.";

print ">> generateKMLPlacemarks method check";
&Geo::Geocalc::generateKMLPlacemarks($outputKmlFilename, @coordinates);

$lat1 = 51.7553;
$lng1 = 19.35027;
$lat2 = 51.73952;
$lng2 = 19.43326;

my $width = 0.5; #km
my %gridCoordinates;

print ">> generateGrid method check";
&Geo::Geocalc::generateGrid($lat1, $lng1, $lat2, $lng2, $width, \%gridCoordinates, $R);

my @gridPlacemarks;

foreach my $key (keys %gridCoordinates) {
	#print @{$gridCoordinates{$key}};
	push @gridPlacemarks, ${$gridCoordinates{$key}}[0], ${$gridCoordinates{$key}}[1], ${$gridCoordinates{$key}}[2], ${$gridCoordinates{$key}}[3],${$gridCoordinates{$key}}[4], ${$gridCoordinates{$key}}[5],${$gridCoordinates{$key}}[6], ${$gridCoordinates{$key}}[7];
}

print ">> generateKMLPlacemarks method check with generated grid coordinates";
&Geo::Geocalc::generateKMLPlacemarks("grid.kml", @gridPlacemarks);

#print ">> isInWaterUnix method check";
#&Geo::Geocalc::isInWaterUnix($lat1,$lng1);
#https://maps.googleapis.com/maps/api/staticmap?center=51.715283,20.344549&size=40x40&maptype=roadmap&sensor=false&zoom=15


#open(FILE, ">$outputKmlFilename") || die "Can not open file!";
#print FILE 
#close FILE;

