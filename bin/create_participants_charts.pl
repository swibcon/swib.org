#!/usr/bin/perl

# Create gender and country charts form Conftools particiants info

use strict;
use warnings;

use Data::Dumper;
use File::Slurp;
use HTML::Template;
use JSON::XS;
use POSIX;
use Readonly;
use XML::XPath;
use XML::XPath::XMLParser;
use YAML::Tiny;

Readonly my $YAML_CONFIG => YAML::Tiny->read('config.yaml')->[0];
Readonly my $SWIB        => $YAML_CONFIG->{swib};
Readonly my $INPUT_FILE  => '../var/src/' . lc($SWIB) . '/participants.xml';
Readonly my $COUNTRY_TEMPLATE =>
  '../etc/html_tmpl/participants_by_country.html.tmpl';
Readonly my $HTML_ROOT      => '../var/html/' . lc($SWIB) . '/';
Readonly my $COUNTRY_OUTPUT => $HTML_ROOT
  . lc($SWIB)
  . '_participants_by_country.html';
Readonly my $GENDER_TEMPLATE =>
  '../etc/html_tmpl/participants_by_gender.html.tmpl';
Readonly my $GENDER_OUTPUT => $HTML_ROOT
  . lc($SWIB)
  . '_participants_by_gender.html';

# non-standard Highmaps codes
Readonly my %HIGHMAPS_MAPPING => ( UK => "GB", );
$Data::Dumper::Sortkeys = 1;

# parser
my $xp = XML::XPath->new( filename => $INPUT_FILE );
my $nodeset;

# extract country data from exported conftool file
$nodeset = $xp->find('/participants/participant/countrycode');
my %country;
foreach my $node ( $nodeset->get_nodelist ) {
  $country{ $node->string_value }++;
}

# create a string with the required JSON data structure
my ( @data, $participant_count, $country_count );
foreach my $country ( sort { $country{$b} <=> $country{$a} } ( keys %country ) )
{
  my $code  = lc( $HIGHMAPS_MAPPING{$country} || $country );
  my %entry = (
    'hc-key' => $code,
    value    => $country{$country},
  );
  push( @data, \%entry );
  $country_count++;
  $participant_count += $country{$country};
}
##print Dumper \@data;
my $data = encode_json \@data;

# create html file with chart
my $tmpl = HTML::Template->new( filename => $COUNTRY_TEMPLATE );
$tmpl->param(
  swib              => $SWIB,
  data              => $data,
  type              => 'registrations',
  participant_count => $participant_count,
  country_count     => $country_count,
  date              => strftime( "%Y-%m-%d %R", localtime ),
);
write_file( $COUNTRY_OUTPUT, $tmpl->output );

# gender statistics
$nodeset = $xp->find('/participants/participant/gender');
my %gender;
foreach my $node ( $nodeset->get_nodelist ) {
  $gender{ $node->string_value }++;
}

@data = ();
foreach my $gender ( sort keys %gender ) {
  my %entry = (
    name => $gender,
    y    => $gender{$gender},
  );
  push( @data, \%entry );
}
$data = encode_json \@data;

$tmpl = HTML::Template->new( filename => $GENDER_TEMPLATE );
$tmpl->param(
  swib => $SWIB,
  data => $data,
  type => 'registrations',
  date => strftime( "%Y-%m-%d %R", localtime ),
);
write_file( $GENDER_OUTPUT, $tmpl->output );

# region statistics
$nodeset = $xp->find('/participants/participant/region');
my %region;
foreach my $node ( $nodeset->get_nodelist ) {
  $region{ $node->string_value }++;
}

# additional statistcs
my %selected_region = (
  dach          => $country{DE} + $country{CH} + $country{AT},
  north_america => $country{US} + $country{CA},
);
$selected_region{western_europe_outside_dach} =
  $region{Western_Europe} - $selected_region{dach};
$selected_region{europe_outside_dach} =
  $region{Western_Europe} + $region{Eastern_Europe} - $selected_region{dach};
$selected_region{rest_without_dach_and_na} =
  $participant_count - $selected_region{dach} - $selected_region{north_america};
$selected_region{rest_without_europe_and_na} =
  $participant_count -
  $selected_region{dach} -
  $selected_region{europe_outside_dach} -
  $selected_region{north_america};

$selected_region{rest_without_western_europe_and_na} =
  $participant_count -
  $selected_region{dach} -
  $selected_region{western_europe_outside_dach} -
  $selected_region{north_america};

# output statistics
print "$participant_count participants from $country_count countries\n";
print Dumper \%region, \%country, \%selected_region, \%gender;

print "Output $HTML_ROOT\*.html\n\n";

