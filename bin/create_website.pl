#!/usr/bin/perl

# Create markdown files from conftools source files

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

Readonly my $YAML_CONFIG   => YAML::Tiny->read('config.yaml')->[0];
Readonly my $SWIB          => $YAML_CONFIG->{swib};
Readonly my $HTML_ROOT     => path( '../var/html/' . lc($SWIB) );
Readonly my $SRC_ROOT      => path( '../var/src/' . lc($SWIB) );
Readonly my $TEMPLATE_ROOT => path('../etc/html_tmpl');
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

# variables used for markdown and rdf output

# author values, keyed by encrypted email address
my %author;


# parser for source data files
my $parser = XML::LibXML->new();

# just in case, create output dir
$HTML_ROOT->mkpath;

# speaker data from "contributors biography"
get_speaker_data();

# output section markdown/html
output_speaker_page();

##print Dumper \%author;

#################################

sub get_speaker_data {

  my $dom = $parser->parse_file( $SRC_ROOT->child( $INPUT_FILE{speakers} ) );

  my @nodes = $dom->findnodes('/papers/paper');
  foreach my $node (@nodes) {

    # the email of the (first) submitting author of the bio identifies
    # the author in other contexts
    my $author_id = email2id( $node->findvalue('./sa_email') );
    my %entry;
    $entry{author_sort} = $node->findvalue('./submitting_author');
    $entry{paper_id}    = $node->findvalue('./paperID');
    $entry{title}       = $node->findvalue('./title');
    $entry{abstract}    = $node->findvalue('./abstract');

    $author{$author_id}{current_bio} = \%entry;
  }
}

sub output_speaker_page {

  my @speakers_loop;
  foreach my $author_id (
    sort {
      $author{$a}{current_bio}{author_sort}
        cmp $author{$b}{current_bio}{author_sort}
    } keys %author
    )
  {
    # only copy the values used in template
    my $entry = {
      author_id => $author_id,
      title     => $author{$author_id}{current_bio}{title},
      abstract  => $author{$author_id}{current_bio}{abstract},
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

sub email2id {
  my $email = shift or croak('param missing');

  # use checksum to protect privacy
  my $id = sha256_hex( lc($email) );

  # prefix with id_ to make values usable as xml id values
  $id = "X$id";

  return $id;
}
