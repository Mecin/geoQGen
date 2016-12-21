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

$lat1 = 51.78738;
$lng1 = 19.36717;
$lat2 = 51.72553;
$lng2 = 19.53987;

my $width = 1; #km
my %gridCoordinates;

print ">> generateGridCoordinates method check";
&Geo::Geocalc::generateGridCoordinates($lat1, $lng1, $lat2, $lng2, $width, \%gridCoordinates, $R);

my @gridPlacemarks;

foreach my $key (keys %gridCoordinates) {
	#print @{$gridCoordinates{$key}};
	push @gridPlacemarks, ${$gridCoordinates{$key}}[0], ${$gridCoordinates{$key}}[1], ${$gridCoordinates{$key}}[2], ${$gridCoordinates{$key}}[3],${$gridCoordinates{$key}}[4], ${$gridCoordinates{$key}}[5],${$gridCoordinates{$key}}[6], ${$gridCoordinates{$key}}[7];
}

print ">> generateKMLPlacemarks method check with generated grid coordinates";
&Geo::Geocalc::generateKMLPlacemarks("grid.kml", @gridPlacemarks);

print ">> generateKMLPolygons method check with generated grid coordinates";
&Geo::Geocalc::generateKMLPolygons("polygons.kml", \%gridCoordinates);

print ">> randomPlacemarkInsidePolygon method check with generated grid coordinates";
my ($rLat, $rLng) = &Geo::Geocalc::randomPlacemarkInsidePolygon(@{$gridCoordinates{1}});

print ">> generateKMLPlacemarks method check with generated random Placemark in first Polygon";
&Geo::Geocalc::generateKMLPlacemarks("randPlace.kml", ($rLat, $rLng));

#print ">> isInWaterUnix method check";
#&Geo::Geocalc::isInWaterUnix($lat1,$lng1);
#http://maps.googleapis.com/maps/api/staticmap?center=51.715283,20.344549&size=40x40&maptype=roadmap&sensor=false&zoom=15&key=
#https://maps.googleapis.com/maps/api/staticmap?center=51.715283,20.344549&size=40x40&maptype=roadmap&sensor=false&zoom=15


#open(FILE, ">$outputKmlFilename") || die "Can not open file!";
#print FILE 
#close FILE;

