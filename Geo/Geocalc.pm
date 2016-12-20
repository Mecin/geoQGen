package Geo::Geocalc;

use 5.006;
use strict;
use warnings;
use Math::Trig;

=head1 NAME

Geo::Geocalc - The great new Geo::Geocalc!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Geo::Geocalc;

	&getDistance($lat1,$lng1,$lat2,$lng2,$R) # calculate distance between two points on Earth, in kilo-meters.

	&getLat($lat1,$lng1,$lng2,$distance,$R) # calculate latitude of the point based on other point and distance on Earth between them.

	&getLng($lat1,$lng1,$lat2,$distance,$R) # calculate longitude of the point based on other point and distance on Earth between them.

	&generateKMLPlacemarks($outputKmlFilename, @coordinates); # generate outputKmlFilename.kml with Placemarks based on an array of coordinates ($lat1, $lng1, $lat2, $lng2, ...)

    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

=head1 AUTHOR

Mecin, C<< <mecin at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-geo-geocalc at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Geo-Geocalc>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Geo::Geocalc


You can also look for information at:

https://github.com/Mecin/geoQGen


=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-Geocalc>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-Geocalc>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Geo-Geocalc>

=item * Search CPAN

L<http://search.cpan.org/dist/Geo-Geocalc/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2016 Mecin.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut
sub generateKMLPlacemarks {
	my $fileName = shift;
	my @coordinates = @_;

	if(scalar(@coordinates)%2 == 0) {

		open(FILE, ">$fileName") || die "Can not open file $fileName!";
		print FILE &getKMLHeader;
		print FILE "		<Folder>";
		print FILE "			<name>Placemarks</name>";
		print FILE "			<description>Generated Placemarks with generateKMLPlacemarks function</description>";

		for(my $i = 0; $i < scalar(@coordinates); $i+=2) {
			print FILE "		<Placemark>";
			print FILE "			<Point>";
			print FILE "				<coordinates>" . $coordinates[$i+1] . ", " . $coordinates[$i] . "</coordinates>";
			print FILE "			</Point>";
			print FILE "		</Placemark>";
		}
		print FILE "		</Folder>";
		print FILE &getKMLClose;
		close FILE;
	} else {
		print "ERROR. Array must contain pairs of coords. Length of array is not an even number (".scalar(@coordinates).")."
	}
};

sub getKMLHeader {
	"<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<kml xmlns=\"http://www.opengis.net/kml/2.2\">
	<Document>"
};

sub getKMLClose {
	"	</Document>
</kml>"
};

sub getMax {
	my $max = $_[0];

	foreach my $tmp (@_) {
		if($max < $tmp) {
			$max = $tmp;
		}
	}
	$max;
};

sub getMin {
	my $min = $_[0];

	foreach my $tmp (@_) {
		if($min > $tmp) {
			$min = $tmp;
		}
	}
	$min;
};

sub generateGrid {
	my ($startLat, $startLng, $stopLat, $stopLng, $width, $tmpLat, $tmpLng, $gridHashRef, $counter, $R) = 0;
	($startLat, $startLng, $stopLat, $stopLng, $width, $gridHashRef, $R) = @_;

	$R //= 6371; #//

	my $maxLat = &getMax(($startLat, $stopLat));
	#print $maxLat;
	my $maxLng = &getMax(($startLng, $stopLng));
	#print $maxLng;
	my $minLat = &getMin(($startLat, $stopLat));
	#print $minLat;
	my $minLng = &getMin(($startLng, $stopLng));
	#print $minLng;

	#&generateKMLPlacemarks("test.kml", ($minLat,$minLng,$minLat,$maxLng,$maxLat,$maxLng,$maxLat,$minLng));	

	$tmpLng = $minLng;

	$counter++;

	while($tmpLng < $maxLng) {
		#print "1. $tmpLng < $maxLng";
		$tmpLat = $minLat;

		while($tmpLat < $maxLat) {
			#print "$maxLat, $maxLng, $minLat, $minLng, $tmpLng, $tmpLat";
			#print "2. $tmpLat < $maxLat";
			#A
			${$gridHashRef}{$counter}[0] = $tmpLat;
			${$gridHashRef}{$counter}[1] = $tmpLng;
			#print "A (${$gridHashRef}{$counter}[2], ${$gridHashRef}{$counter}[3])";
			#B
			${$gridHashRef}{$counter}[2] = ${$gridHashRef}{$counter}[0];
			${$gridHashRef}{$counter}[3] = &getLng(${$gridHashRef}{$counter}[0], ${$gridHashRef}{$counter}[1], ${$gridHashRef}{$counter}[0], $width, $R);
			#print "B (${$gridHashRef}{$counter}[4], ${$gridHashRef}{$counter}[5])";
			#C
			${$gridHashRef}{$counter}[4] = &getLat(${$gridHashRef}{$counter}[2], ${$gridHashRef}{$counter}[3], ${$gridHashRef}{$counter}[3], $width, $R);
			${$gridHashRef}{$counter}[5] = ${$gridHashRef}{$counter}[3]; 
			#print "C (${$gridHashRef}{$counter}[6], ${$gridHashRef}{$counter}[7])";
			#D
			${$gridHashRef}{$counter}[6] = &getLat(${$gridHashRef}{$counter}[0], ${$gridHashRef}{$counter}[1], ${$gridHashRef}{$counter}[0], $width, $R);
			${$gridHashRef}{$counter}[7] = ${$gridHashRef}{$counter}[1];
			#print "D (${$gridHashRef}{$counter}[8], ${$gridHashRef}{$counter}[9])";


			$tmpLat = ${$gridHashRef}{$counter}[4];
			$counter++;
		}
		$tmpLng = ${$gridHashRef}{($counter-1)}[3];
	}
};

sub isInWaterUnix {
	my ($lat, $lng, $imgURL) = 0;
	($lat, $lng) = @_;

	$imgURL = "http://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng&size=40x40&maptype=roadmap&sensor=false&zoom=15";
	`wget $imgURL`;
	
	0;
};

sub getDistance {
	my ($lat1, $lng1, $lat2, $lng2, $R) = 0;
	($lat1, $lng1, $lat2, $lng2, $R) = @_;

	return acos(sin(deg2rad($lat1))*sin(deg2rad($lat2))+cos(deg2rad($lat1))*cos(deg2rad($lat2))*cos(deg2rad($lng1)-deg2rad($lng2)))*$R;
};

sub getLat {
	my ($lat1, $lng1, $lng2, $dist, $R) = 0;
	($lat1, $lng1, $lng2, $dist, $R) = @_;
	
	return (rad2deg(asin(sin(deg2rad($lat1))*cos($dist/$R)+cos(deg2rad($lat1))*sin($dist/$R)*cos(0))));
};

sub getLng {
	my ($lat1, $lng1, $lat2, $dist, $R) = 0;
	($lat1, $lng1, $lat2, $dist, $R) = @_;

	return (rad2deg(deg2rad($lng1) + atan2(sin(90)*sin($dist/$R)*cos(deg2rad($lat1)), cos($dist/$R)-sin(deg2rad($lat1))*sin(deg2rad($lat2)))));
};

1; # End of Geo::Geocalc
