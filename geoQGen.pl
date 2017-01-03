#!/usr/bin/perl -w

use strict;
use warnings;

use Geo::Geocalc;
use GD;
#use Geo::Geocalc qw(&getDistance);

# auto space
$, = " ";

# auto line breaker
$\ = "\n";

# functions

sub isInWaterUnix {
	my ($lat, $lng, $size, $key, $imgURL, $cmd, $rb, $gb, $bb, $counter, $err) = 0;
	($lat, $lng, $size, $key) = @_;

	$imgURL = "http://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&size=$size"."x"."$size&maptype=roadmap&sensor=false&zoom=15&key=$key";
	$cmd = "wget \"$imgURL\" -O static -o wgetlog";
	`$cmd`;

	my $image = new GD::Image('static') or die "Can not create GD::Image!";

	# rgb for blue color of Google Maps water areas
	$rb = 163;
	$gb = 204;
	$bb = 255;

	$err = 2;
	$counter = 0;

	for (my $i = 0; $i < $size; $i+=2) {
		my $index = $image->getPixel($i,$i);
		my ($r,$g,$b) = $image->rgb($index);

		if(
			(($rb-$err) <= $r && $r <= ($rb+$err)) &&
			(($gb-$err) <= $g && $g <= ($gb+$err)) &&
			(($bb-$err) <= $b && $b <= ($bb+$err))
			) {

			$counter++;
		}
	}

	unlink "static";
	if($counter >= int($size/4)) {
		1;
	} else {
		0;
	}
};

sub getGoogleApiKey {
	my $fileName = shift;
	
	open(FILE, "<$fileName") || die "Can not open file $fileName!";
	my $key = <FILE>;
	close FILE;
	chomp($key);
	$key;
};

# main

# nonwater
my $lat1 = 51.715283;
my $lng1 = 20.344549;
my $size = 10; # size x size pixels to analyse
my $keyFileName = "key";
#if(&isInWaterUnix($lat1, $lng1, $size, &getGoogleApiKey($keyFileName))) {
#	print "Water";
#}

# water
#$lat1 = 51.80407;
#$lng1 = 19.44236;
#if(&isInWaterUnix($lat1, $lng1, $size, &getGoogleApiKey($keyFileName))) {
#	print "Water";
#}

# sea
#$lat1 = 55.47885;
#$lng1 = 18.45703;
#if(&isInWaterUnix($lat1, $lng1, $size, &getGoogleApiKey($keyFileName))) {
#	print "Water";
#}

# generate grid

# Poland corners
#$lat1 = 54.72462;
#$lng1 = 14.28222;
#my $lat2 = 49.06666;
#my $lng2 = 23.81835;

# Lodzkie corners
#$lat1 = 52.26143;
#$lng1 = 18.09448;
#my $lat2 = 51.26878;
#my $lng2 = 20.8081;

# Lodz corners
#$lat1 = 51.82771;
#$lng1 = 19.31533;
#my $lat2 = 51.66745;
#my $lng2 = 19.62432;

# Piotrkow corners
$lat1 = 51.44138;
$lng1 = 19.62982;
my $lat2 = 51.37488;
my $lng2 = 19.77075;


my $R = 6378.41;
my $width = 1; # km x km
my %gridCoordinates;

print "";
print ">> generateGridCoordinates ...";
&Geo::Geocalc::generateGridCoordinates($lat1, $lng1, $lat2, $lng2, $width, \%gridCoordinates, $R, 433);
print ">> Done.";
print "";

print scalar(keys %gridCoordinates) . " sectors $width x $width (km) generated.";

print "";
print ">> generateKMLPolygons method check with generated grid coordinates";
&Geo::Geocalc::generateKMLPolygons("polygons.kml", \%gridCoordinates);
print ">> Done.";
print "";

print "";
print ">> generate quests coordinates for each sector";

my ($qLat, $qLng) = 0;
my ($lLat, $lLng) = 0;
my @questsCoords;
my $nOT = 10; # number of tries per each generating point
my $nOQ = 5; # number of quests per sector
my $minDistance = $width/$nOQ; # min distance between each quest locations (km).
my @globalPlacemarks;

foreach my $sector (keys %gridCoordinates) {

	@questsCoords = ();

	for(my $i = 0; $i < $nOQ; $i++) {

		$nOT = 10;

		while($nOT > 0) {

			($qLat, $qLng) = &Geo::Geocalc::randomPlacemarkInsidePolygon(@{$gridCoordinates{$sector}});

			if(&isInWaterUnix($qLat, $qLng, $size, &getGoogleApiKey($keyFileName))) {
				$nOT--;
				print "Water (".(10-$nOT)."/10).";
			} else {
				my $length = scalar @questsCoords;

				if($length == 0) {
					$nOT = 0;
					push @questsCoords, $qLat, $qLng;
				} else {
					$lLat = $questsCoords[$length-2];
					$lLng = $questsCoords[$length-1];

					if (&Geo::Geocalc::getDistance($qLat, $qLng, $lLat, $lLng, $R) >= $minDistance) {
						push @questsCoords, $qLat, $qLng;
						$nOT = 0;
					} else {
						$nOT--;
						print "Distance too low (".(10-$nOT)."/10).";
					}
				}
			}
		}
	}

	my $len = scalar(@questsCoords);

	while($len < ($nOQ*2)) {
		push @questsCoords, 0, 0;
		$len = scalar(@questsCoords);
	}

	push @globalPlacemarks, @questsCoords;
	push @{$gridCoordinates{$sector}}, @questsCoords;
}

print ">> Done.";
print "";

print "";
print ">> generateKMLPlacemarks with generated random Placemark ";
&Geo::Geocalc::generateKMLPlacemarks("randPlace.kml", @globalPlacemarks);
print ">> Done.";
print "";

print "";
print ">> generating sql scripts";
my $qNum;
open(FILE_SECTOR, ">sector.sql") || die "Can not open file sector.sql!";

open(FILE_QUEST, ">quest.sql") || die "Can not open file quest.sql!";

foreach my $sector (sort { $a <=> $b } keys %gridCoordinates) {

	print FILE_SECTOR "INSERT INTO sector (a1, a2, b1, b2, c1, c2, d1, d2) VALUES ('$gridCoordinates{$sector}[0]', '$gridCoordinates{$sector}[1]', '$gridCoordinates{$sector}[2]', '$gridCoordinates{$sector}[3]', '$gridCoordinates{$sector}[4]', '$gridCoordinates{$sector}[5]', '$gridCoordinates{$sector}[6]', '$gridCoordinates{$sector}[7]');";

	$qNum = 1;
	
	for(my $i = 1; $i < ((2*$nOQ)+1); $i+=2) {
		
		print FILE_QUEST "INSERT INTO quest (lat, lng, pos, sid) VALUES ('".$gridCoordinates{$sector}[(7+$i)]."', '".$gridCoordinates{$sector}[(7+$i+1)]."', '$qNum', '$sector');";
		$qNum++;

	}
}

close FILE_QUEST;

close FILE_SECTOR;

print ">> Done.";
print "";
