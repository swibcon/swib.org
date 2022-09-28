#!/usr/bin/perl

# Create markdown files from conftools source files
# and a turtle file with main content as RDF

use strict;
use warnings;
use utf8;

use Carp;
use Data::Dumper;
use Digest::SHA qw(sha256_hex);
use HTML::Template;
use Path::Tiny;
use Readonly;
use XML::LibXML;
use YAML::Tiny;

$Data::Dumper::Sortkeys = 1;

Readonly my $ROOT_URI      => 'https://swib.org/';
Readonly my $YAML_CONFIG   => YAML::Tiny->read('config.yaml')->[0];
Readonly my $SWIB          => $YAML_CONFIG->{swib};
Readonly my $HTML_ROOT     => path( '../var/html/' . lc($SWIB) );
Readonly my $SRC_ROOT      => path( '../var/src/' . lc($SWIB) );
Readonly my $TEMPLATE_ROOT => path('../etc/html_tmpl');
Readonly my $RDF_FILE      => $HTML_ROOT->child( lc($SWIB) . '.ttl' );
Readonly my %INPUT_FILE    => (
  abstracts => 'abstracts.xml',
  speakers  => 'speakers.xml',
  sessions  => 'sessions.xml',
);
Readonly my %PAGE => (
  speakers => {
    template => 'speakers.md.tmpl',
    output   => 'speakers.md',
  },
);

## TODO param for html|rdf|all output

# variables used for markdown and rdf output

# person values, keyed by encrypted email address
my %person;

# parser for source data files
my $parser = XML::LibXML->new();

# just in case, create output dir
$HTML_ROOT->mkpath;

# speaker data from "contributors biography"
get_speaker_data();

#### output section for markdown/html

output_speaker_page();

print Dumper \%person;

### output secton for rdf

output_rdf();

#################################

sub get_speaker_data {

  my $dom = $parser->parse_file( $SRC_ROOT->child( $INPUT_FILE{speakers} ) );

  my @nodes = $dom->findnodes('/papers/paper');
  foreach my $node (@nodes) {

    # the email of the (first) submitting author of the bio identifies
    # the author in other contexts
    my $author_id = email2id( $node->findvalue('./sa_email') );
    my %entry     = (
      author_sort => $node->findvalue('./submitting_author'),
      paper_id    => $node->findvalue('./paperID'),
      title       => $node->findvalue('./title'),
      abstract    => $node->findvalue('./abstract'),
    );

    $person{$author_id}{current_bio} = \%entry;
    $person{$author_id}{is_speaker}  = 1;
  }
}

sub output_speaker_page {

  my @speakers_loop;
  foreach my $author_id (
    sort {
      $person{$a}{current_bio}{author_sort}
        cmp $person{$b}{current_bio}{author_sort}
    } keys %person
    )
  {
    my %author = %{ $person{$author_id} };

    # skip non-authors and those without current bio
    next unless ( $author{is_speaker} and exists $author{current_bio} );

    # only copy the values used in template
    my $entry = {
      author_id => $author_id,
      title     => $author{current_bio}{title},
      abstract  => $author{current_bio}{abstract},
    };
    push( @speakers_loop, $entry );
  }
  my $tmpl = HTML::Template->new(
    filename => $TEMPLATE_ROOT->child( $PAGE{speakers}{template} ) );
  $tmpl->param(
    swib          => $SWIB,
    speakers_loop => \@speakers_loop,
  );
  my $outfile = $HTML_ROOT->child( $PAGE{speakers}{output} );
  $outfile->spew_utf8( $tmpl->output );
}

sub output_rdf {

  # concatenate text blocks with turtle statements
  my $rdf_txt = build_prefix_rdf();
  $rdf_txt .= build_person_rdf();
  $RDF_FILE->spew_utf8($rdf_txt);
}

sub build_person_rdf {
  my $rdf_txt;
  foreach my $id ( keys %person ) {
    my $pers_uri = $ROOT_URI . "person/$id";

    # here for identifying the person if more precise name values or IDs are
    # missing
    $rdf_txt .=
      "<$pers_uri> foaf:name \"" . $person{$id}{current_bio}{title} . "\" . \n";
    $rdf_txt .=
        "<$pers_uri> dct:description '''"
      . $person{$id}{current_bio}{abstract}
      . "''' . \n";
  }
  return $rdf_txt;
}

sub build_prefix_rdf {
  my $prefixes = <<'EOF';
@prefix dct: <http://purl.org/dc/terms/> .
@prefix schema: <http://schema.org/> .
@prefix foaf: <http://xmlns.com/foaf/0.1/> .

EOF

  return $prefixes;
}

sub email2id {
  my $email = shift or croak('param missing');

  # use checksum to protect privacy
  my $id = sha256_hex( lc($email) );

  # prefix with id_ to make values usable as xml id values
  $id = "X$id";

  return $id;
}
