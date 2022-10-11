#!/usr/bin/perl

# Create markdown files from conftools source files
# and a turtle file with main content as RDF

use strict;
use warnings;
use utf8;

use Carp;
use Data::Dumper;
use DateTime;
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
Readonly my @DAYS          => @{ $YAML_CONFIG->{days} };
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
  programme => {
    template => 'programme.md.tmpl',
    output   => 'programme.md',
  },
);
## maximum used in conftool 2022
Readonly my $MAX_AUTHORS_PER_PRESENTATION  => 6;
Readonly my $MAX_PRESENTATIONS_PER_SESSION => 7;

## TODO param for html|rdf|all output

# variables used for markdown and rdf output

# speaker values, keyed by encrypted email address
my %speaker;

# abstracts/contributions, keyed by conftool ids
my %abstract;

# sessions with linked abstracts, keyed by shortname
my %session;

# parser for source data files
my $parser = XML::LibXML->new();

# just in case, create output dir
$HTML_ROOT->mkpath;

# speaker data from "contributors biography"
get_speaker_data();

# presentation abstracts from "presentation"
get_abstract_data();

# sesion structure
get_session_data();

#print Dumper %session;

#### output section for markdown/html

output_speaker_page();
output_programme_page();

foreach my $page (qw/ index registration general-information history coc /) {
  output_static_page($page);
}

##print Dumper \%speaker;

### output secton for rdf

output_rdf();

#################################

sub get_speaker_data {

  my $dom = $parser->parse_file( $SRC_ROOT->child( $INPUT_FILE{speakers} ) );

  my @nodes = $dom->findnodes('/papers/paper');
  foreach my $node (@nodes) {

    # the email of the (first) submitting author of the bio identifies
    # the author in other contexts
    my $author_id = email2id( $node->findvalue('./authors_formatted_1_email') );
    my %entry     = (
      author_sort => $node->findvalue('./authors_formatted_1_name'),
      paper_id    => $node->findvalue('./paperID'),
      title       => $node->findvalue('./title'),
      abstract    => $node->findvalue('./abstract'),
    );

    $speaker{$author_id}{current_bio} = \%entry;
    $speaker{$author_id}{is_speaker}  = 1;
  }
}

sub get_abstract_data {

  my $dom = $parser->parse_file( $SRC_ROOT->child( $INPUT_FILE{abstracts} ) );

  my @nodes = $dom->findnodes('/papers/paper');
  foreach my $node (@nodes) {

    # skip irrelevant papers
    my $contribution_type = $node->findvalue('./contribution_type');
    next
      unless $contribution_type eq 'Presentation'
      or $contribution_type eq 'Workshop';
    my $acceptance_status = $node->findvalue('./acceptance_status');
    next unless $acceptance_status gt 0;

    # read values
    my $abstract_id = $node->findvalue('./paperID');
    my %entry       = (
      abstract_id   => $node->findvalue('./paperID'),
      title         => $node->findvalue('./title'),
      abstract      => $node->findvalue('./abstract'),
      authors       => get_authors($node),
      organisations => get_organisations($node),
    );

    # remove empty abstracts
    if ( $entry{abstract} eq '.' ) {
      delete $entry{abstract};
    }

    # remove empty author/organisation
    # (indicated by '.' in fist and lastname fields
    if ( $node->findvalue('./authors') eq '., .' ) {
      $entry{authors}       = [];
      $entry{organisations} = {};
    }

    $abstract{$abstract_id} = \%entry;
  }
}

sub get_session_data {

  my $dom = $parser->parse_file( $SRC_ROOT->child( $INPUT_FILE{sessions} ) );

  my @nodes = $dom->findnodes('/sessions/session');
  foreach my $node (@nodes) {

    my $session_id = $node->findvalue('./session_short');
    die "Session short title (used as ID) missing for session "
      . $node->findvalue('./session_ID') . "\n"
      unless $session_id;

    my %entry = (
      start => $node->findvalue('./session_start'),
      end   => $node->findvalue('./session_end'),
      title => $node->findvalue('./session_title'),
    );

    if ( $entry{start} =~ m/^(\S+) (\S+)$/ ) {
      $entry{start_date} = $1;
      $entry{start_time} = $2;
    } else {
      die "Strange start $entry{start}\n";
    }
    if ( $entry{end} =~ m/^(\S+) (\S+)$/ ) {
      $entry{end_date} = $1;
      $entry{end_time} = $2;
    } else {
      die "Strange end $entry{end}\n";
    }

    # get sequence of presentations
    my @presentations;
    for ( my $i = 1 ; $i <= $MAX_PRESENTATIONS_PER_SESSION ; $i++ ) {
      next unless $node->findvalue("./p${i}_paperID");

      push( @presentations, $node->findvalue("./p${i}_paperID") );
    }
    $entry{presentations} = \@presentations;

    $session{ $node->findvalue('./session_short') } = \%entry;
  }
  return \%session;
}

sub output_speaker_page {

  # sort alphabetically by last name
  my @speakers_loop;
  foreach my $author_id (
    sort {
      $speaker{$a}{current_bio}{author_sort}
        cmp $speaker{$b}{current_bio}{author_sort}
    } keys %speaker
    )
  {
    my %author = %{ $speaker{$author_id} };

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
    filename => $TEMPLATE_ROOT->child( $PAGE{speakers}{template} ),
    utf8     => 1
  );
  $tmpl->param(
    swib          => $SWIB,
    lc_swib       => lc($SWIB),
    speakers_loop => \@speakers_loop,
  );
  my $outfile = $HTML_ROOT->child( $PAGE{speakers}{output} );
  $outfile->spew_utf8( $tmpl->output );
}

sub output_programme_page {

  my @days_loop;

  foreach my $day (@DAYS) {
    my ( $day_id, $day_of_week, $date );
    if ( $day =~ m/^DAY (\d) \| (\w+), (\S+)$/ ) {
      $day_id      = $1;
      $day_of_week = $2;
      $date        = $3;
    } else {
      die "Wrong day format $day\n";
    }

    # sequence by start session start
    my @sessions_loop;
    foreach my $session_id (
      sort { $session{$a}{start} cmp $session{$b}{start} }
      keys %session
      )
    {
      ## iterate through all session and skip those for different day
      next unless ( $session{$session_id}{start_date} eq $date );

      ##print "$session{$session_id}{start_date} $session_id\n";
      my %entry = (
        session_id    => $session_id,
        session_title => $session{$session_id}{title},
        start_time    => $session{$session_id}{start_time},
        end_time      => $session{$session_id}{end_time},
        epoch         => time2epoch( $date, $session{$session_id}{start_time} ),
      );

      my @presentations = @{ $session{$session_id}{presentations} };
      my @abstracts_loop;
      foreach my $abstract_id (@presentations) {
        my $entry = {
          abstract_id        => $abstract_id,
          abstract_title     => $abstract{$abstract_id}{title},
          authors_loop       => mk_authors_loop($abstract_id),
          organisations_loop => mk_organisations_loop($abstract_id),
        };
        ## skip empty abstracts
        if ( $abstract{$abstract_id}{abstract} ) {
          $entry->{abstract} = $abstract{$abstract_id}{abstract};
        }
        push( @abstracts_loop, $entry );
      }
      $entry{abstracts_loop} = \@abstracts_loop;
      push( @sessions_loop, \%entry );
    }

    my $entry = {
      day_id        => $day_id,
      day           => $day,
      sessions_loop => \@sessions_loop,
    };
    push( @days_loop, $entry );
  }

  my $tmpl = HTML::Template->new(
    filename          => $TEMPLATE_ROOT->child( $PAGE{programme}{template} ),
    utf8              => 1,
    loop_context_vars => 1
  );
  $tmpl->param(
    swib      => $SWIB,
    lc_swib   => lc($SWIB),
    days_loop => \@days_loop,
  );
  my $outfile = $HTML_ROOT->child( $PAGE{programme}{output} );
  $outfile->spew_utf8( $tmpl->output );
}

sub output_static_page {
  my $page = shift or croak('param missing');

  my $tmpl = HTML::Template->new(
    filename => $TEMPLATE_ROOT->child("${page}.md.tmpl"),
    utf8     => 1,
  );
  $tmpl->param(
    swib    => $SWIB,
    lc_swib => lc($SWIB),
  );
  my $outfile = $HTML_ROOT->child("${page}.md");
  $outfile->spew_utf8( $tmpl->output );
}

sub output_rdf {

  # concatenate text blocks with turtle statements
  my $rdf_txt = build_prefix_rdf();
  $rdf_txt .= build_speaker_rdf();
  $RDF_FILE->spew_utf8($rdf_txt);
}

sub build_speaker_rdf {
  my $rdf_txt;
  foreach my $id ( keys %speaker ) {
    my $pers_uri = $ROOT_URI . "person/$id";

    # here for identifying the speaker if more precise name values or IDs are
    # missing
    $rdf_txt .= "<$pers_uri> a schema:Person .\n";
    $rdf_txt .=
        "<$pers_uri> schema:name \""
      . $speaker{$id}{current_bio}{title}
      . "\" .\n";
    $rdf_txt .=
        "<$pers_uri> dct:description '''"
      . $speaker{$id}{current_bio}{abstract}
      . "''' .\n";
    $rdf_txt .= "\n";
  }
  return $rdf_txt;
}

sub build_prefix_rdf {
  my $prefixes = <<'EOF';
@prefix dct: <http://purl.org/dc/terms/> .
@prefix schema: <http://schema.org/> .

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

sub get_authors {
  my $node = shift or croak('param missing');

  # use the string values for extracting affiliation and speaker status
  my @authors_indexed =
    split( /, /, $node->findvalue("./authors_formatted_index") );

  my @authors;
  for ( my $i = 1 ; $i <= $MAX_AUTHORS_PER_PRESENTATION ; $i++ ) {
    my $field_prefix = "authors_formatted_${i}";
    next unless $node->findvalue("./${field_prefix}_name");

    # use hashed email as id
    my $id = email2id( $node->findvalue("./${field_prefix}_email") );

    # remove speaker indicator from name string
    my $name = $node->findvalue("./${field_prefix}_name");

    $name =~ s/(.*?)\*/$1/;
    my %entry = (
      author_id    => $id,
      name         => $name,
      organisation => $node->findvalue("./${field_prefix}_organisation"),
      orcid        => $node->findvalue("./${field_prefix}_orcid"),
    );

    # add index and speaker status
    foreach my $author_indexed (@authors_indexed) {
      if ( $author_indexed =~ m/^$entry{name}(\*?) \((\d(,\d)?)\)/ ) {
        if ( $1 ne '' ) {
          $entry{speaker} = 1;
        }
        $entry{index} = $2;
      }
    }
    push( @authors, \%entry );
  }

  return \@authors;
}

sub get_organisations {
  my $node = shift or croak('param missing');

  my %organisation;
  my @organisations_indexed =
    split( /; /, $node->findvalue("./organisations") );
  if ( scalar(@organisations_indexed) gt 1 ) {
    foreach my $org (@organisations_indexed) {
      my ( $index, $name ) = split( /: /, $org );
      $organisation{$index} = $name;
    }
  } else {
    $organisation{0} = $organisations_indexed[0];
  }

  return \%organisation;
}

sub mk_authors_loop {
  my $abstract_id = shift or croak('param missing');

  my @authors_loop = @{ $abstract{$abstract_id}{authors} };

  # remove fields not used in template
  foreach my $author (@authors_loop) {

    # remove speaker links if author is not a speaker or has no bio
    if ( not $speaker{ $author->{author_id} } ) {
      delete( $author->{author_id} );
    }

    # remove organisation (is given separately) and speaker flag
    delete( $author->{organisation} );
    delete( $author->{speaker} );
  }

  return \@authors_loop;
}

sub mk_organisations_loop {
  my $abstract_id = shift or croak('param missing');

  my @organisations_loop;

  my %organisations = %{ $abstract{$abstract_id}{organisations} };
  if ( scalar( keys %organisations ) gt 1 ) {
    foreach my $index ( keys %organisations ) {
      my %entry = (
        index => $index,
        name  => $organisations{$index},
      );
      push( @organisations_loop, \%entry );
    }
  } else {
    push( @organisations_loop, { name => $organisations{0} } );
  }

  return \@organisations_loop;
}

sub time2epoch {
  my $date = shift or croak('param missing');
  my $time = shift or croak('param missing');

  # convert UTIC date/time to epoch, which is used by
  # the zonestamp service
  my ( $year, $month, $day ) = split( /\-/, $date );
  my ( $hour, $minute ) = split( /:/, $time );

  my $dt = DateTime->new(
    year      => $year,
    month     => $month,
    day       => $day,
    hour      => $hour,
    minute    => $minute,
    time_zone => 'UTC',
  );

  return $dt->epoch;
}
