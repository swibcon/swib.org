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
Readonly my $MEDIA_ROOT    => path( '../var/media_info/' . lc($SWIB) );
Readonly my $TEMPLATE_ROOT => path('../etc/html_tmpl');
Readonly my $RDF_FILE      => $HTML_ROOT->child( lc($SWIB) . '.ttl' );
Readonly my %MEDIA_TYPE    => %{ $YAML_CONFIG->{media_types} };
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
## maximum used in conftool 2022 was 6 authors, 2023 11
Readonly my $MAX_AUTHORS_PER_PRESENTATION  => 12;
Readonly my $MAX_PRESENTATIONS_PER_SESSION => 7;

## TODO param for html|rdf|all output

# variables used for markdown and rdf output

# persons for RDF output
my %person;

# speaker values, keyed by encrypted email address
my %speaker;

# abstracts/contributions, keyed by conftool ids
my %abstract;

# sessions with linked abstracts, keyed by shortname
my %session;

# media about the talks
my %media;

# parser for source data files
my $parser = XML::LibXML->new();

# just in case, create output dir
$SRC_ROOT->mkpath;
$HTML_ROOT->mkpath;

# generate static pages

foreach my $page (qw/ index registration general-information history coc /) {
  output_static_page($page);
}

# after creation of the programme, the real content can be inserted
if (@ARGV and $ARGV[0] eq 'plain') {

  foreach my $page (qw/ programme speakers registration /) {
    output_static_substitute($page);
  }

} else {

  # presentation abstracts from "presentation"
  get_abstract_data();

  # speaker data from "contributors biography"
  get_speaker_data();

  # sesion structure
  get_session_data();

  # templates are generated/updated every time, but has to be copied and filled
  # in after the session once
  generate_templates();

  # get and verfiy media information
  get_media_data();

  ##print Dumper \%abstract; exit;

  #### output section for markdown/html

  output_speaker_page();
  output_programme_page();
  output_session_slides();

  ### output secton for rdf

  output_rdf();

}

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

    # collect values for RDF output
    $person{$author_id}{bio} = $entry{abstract};
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
      or $contribution_type eq 'Workshop'
      or $contribution_type eq 'Collocated Event';
    my $acceptance_status = $node->findvalue('./acceptance_status');
    next unless $acceptance_status gt 0;

    # read values
    my $abstract_id = $node->findvalue('./paperID');
    my %entry       = (
      abstract_id   => $node->findvalue('./paperID'),
      title         => $node->findvalue('./title'),
      abstract      => $node->findvalue('./abstract'),
      forum_link         => $node->findvalue('./presenting_author_cv'),
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
      start               => $node->findvalue('./session_start'),
      end                 => $node->findvalue('./session_end'),
      title               => $node->findvalue('./session_title'),
      chair1_name         => $node->findvalue('./chair1_name'),
      chair2_name         => $node->findvalue('./chair2_name'),
      chair1_organisation => $node->findvalue('./chair1_organisation'),
      chair2_organisation => $node->findvalue('./chair2_organisation'),
      session_info        => $node->findvalue('./session_info'),
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

sub get_media_data {

  # for each media type, a .yaml file should exist
  foreach my $media_type ( keys %MEDIA_TYPE ) {
    my $media_info = $MEDIA_ROOT->child("$media_type.yaml");
    if ( $media_info->is_file ) {
      $media{$media_type} = YAML::Tiny->read($media_info)->[0];
    }
  }
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

    # add orcid from person info
    if ( $person{$author_id}{orcid} ) {
      $entry->{orcid} = $person{$author_id}{orcid};
    }

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
  my @days_index_loop;

  foreach my $day (@DAYS) {
    my ( $day_no, $day_of_week, $date );
    if ( $day =~ m/^DAY (\d) \| (\w+), (\S+)$/ ) {
      $day_no      = $1;
      $day_of_week = $2;
      $date        = $3;
    } else {
      die "Wrong day format $day\n";
    }
    push( @days_index_loop, { id => "day$day_no", label => "Day $day_no" } );

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
        chair1_name   => $session{$session_id}{chair1_name},
        chair2_name   => $session{$session_id}{chair2_name},
        start_time    => $session{$session_id}{start_time},
        end_time      => $session{$session_id}{end_time},
        epoch         => time2epoch( $date, $session{$session_id}{start_time} ),
        session_info  => $session{$session_id}{session_info},
      );

      my @presentations = @{ $session{$session_id}{presentations} };
      my @abstracts_loop;
      foreach my $abstract_id (@presentations) {
        my $entry = {
          abstract_id        => $abstract_id,
          abstract_title     => $abstract{$abstract_id}{title},
	  forum_link     => $abstract{$abstract_id}{forum_link},
          authors_loop       => mk_authors_loop($abstract_id),
          organisations_loop => mk_organisations_loop($abstract_id),
        };
        ## skip empty abstracts
        if ( $abstract{$abstract_id}{abstract} ) {
          $entry->{abstract} = $abstract{$abstract_id}{abstract};
        }

        # media links
        my @media_loop;
        ## q&d sequence
        foreach my $media_type ( sort keys %MEDIA_TYPE ) {
          next unless $media{$media_type}{$abstract_id};
          my $url = mk_url(
            $media_type,
            $MEDIA_TYPE{$media_type}{url_type},
            $media{$media_type}{$abstract_id}
          );
          push(
            @media_loop,
            {
              url   => $url,
              label => $MEDIA_TYPE{$media_type}{label},
            }
          );
        }
        $entry->{media_loop} = \@media_loop;

        push( @abstracts_loop, $entry );
      }
      $entry{abstracts_loop} = \@abstracts_loop;
      push( @sessions_loop, \%entry );
    }

    my $entry = {
      day_no        => $day_no,
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
    swib            => $SWIB,
    lc_swib         => lc($SWIB),
    days_loop       => \@days_loop,
    days_index_loop => \@days_index_loop,
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

sub output_static_substitute {
  my $page = shift or croak('param missing');

  my $tmpl = HTML::Template->new(
    filename => $TEMPLATE_ROOT->child("tbd.md.tmpl"),
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
  $rdf_txt .= build_person_rdf();
  $rdf_txt .= build_event_rdf();
  $RDF_FILE->spew_utf8($rdf_txt);
}

sub output_session_slides {

  my @slides_loop;
  foreach my $session_id (
    sort { $session{$a}{start} cmp $session{$b}{start} }
    keys %session
    )
  {

    # skip sessions without presentations (such as coffee breaks)
    next unless scalar @{ $session{$session_id}{presentations} } gt 0;

    print "$session{$session_id}{start_date} $session_id\n";

    my $start_date = $session{$session_id}{start_date};
    my $start_time = $session{$session_id}{start_time};
    my ( $year, $month, $day ) = split( /\-/, $start_date );
    my ( $hour, $minute ) = split( /:/, $start_time );
    my %entry = (
      swib          => $SWIB,
      session_title => $session{$session_id}{title},
      start_date    => $start_date,
      start_time    => $start_time,
      end_time      => $session{$session_id}{end_time},
      year          => $year,
      month         => $month,
      day           => $day,
      hours         => $hour,
      minutes       => $minute,
      chair1_name   => $session{$session_id}{chair1_name},
      chair2_name   => $session{$session_id}{chair2_name},
      ##    chair1_organisation => $session{$session_id}{chair1_organisation},
      ##    chair2_organisation => $session{$session_id}{chair2_organisation},
    );

    my @presentations = @{ $session{$session_id}{presentations} };
    my @abstracts_loop;
    foreach my $abstract_id (@presentations) {
      my $entry = {
        abstract_title => $abstract{$abstract_id}{title},
        authors_loop   => mk_authors_loop($abstract_id),
        ##   organisations_loop => mk_organisations_loop($abstract_id),
      };
      push( @abstracts_loop, $entry );
    }
    $entry{abstracts_loop} = \@abstracts_loop;

    # overide slide for workshops
    if ( $session_id eq 'ws' ) {
      %entry = (
        swib           => $SWIB,
        session_title  => $session{$session_id}{title},
        abstracts_loop => [
          { abstract_title => 'all booked out' },
          { abstract_title => 'Next conference session at Thursday 14 h UTC' },
        ],
      );
    }

    my $tmpl = HTML::Template->new(
      filename          => $TEMPLATE_ROOT->child("session.md.tmpl"),
      utf8              => 1,
      loop_context_vars => 1
    );
    $tmpl->param( \%entry );

    # output session background slides
    my $outfile = $HTML_ROOT->child("sessions")->child("${session_id}.md");
    $outfile->spew_utf8( $tmpl->output );

    # now repeat for announcement slides
    $tmpl->param( announce => 1, );

    $outfile =
      $HTML_ROOT->child("sessions")->child("${session_id}_announce.md");
    $outfile->spew_utf8( $tmpl->output );

    # entry for the slide index
    my %index_entry = (
      session_id    => $session_id,
      session_title => $session{$session_id}{title},
      start_time    => $session{$session_id}{start_time},
      start_date    => $session{$session_id}{start_date},
    );
    push( @slides_loop, \%index_entry );
  }

  # session slide index
  my $tmpl = HTML::Template->new(
    filename => $TEMPLATE_ROOT->child("session_index.md.tmpl"),
    utf8     => 1,
  );
  $tmpl->param(
    swib        => $SWIB,
    slides_loop => \@slides_loop,
  );
  my $outfile = $HTML_ROOT->child("sessions")->child("index.md");
  $outfile->spew_utf8( $tmpl->output );

}

sub generate_templates {

  # collect lines for all templates
  my @lines;
  foreach my $session_id (
    sort { $session{$a}{start} cmp $session{$b}{start} }
    keys %session
    )
  {

    my @presentations = @{ $session{$session_id}{presentations} };
    next unless scalar(@presentations) gt 0;

    push( @lines, "\n# $session_id: $session{$session_id}{title}\n" );

    foreach my $abstract_id (@presentations) {
      push( @lines, "# $abstract{$abstract_id}{title}" );
      push( @lines, "$abstract_id: \n" );
    }
  }

  # output as template, for multiple media types
  my $head =
    "# Format for media types\n - slides: filename,\n - youtube: full URL\n\n";
  my $file = $MEDIA_ROOT->child("media.template.yaml");
  $file->spew_utf8( $head, join( "\n", @lines ) );
}

sub build_person_rdf {
  my $rdf_txt = '';

  foreach my $id ( keys %person ) {

    # skip empty name fields
    warn 'empty name - maybe differing email ' .
       'addresses for speaker and presentation: ',
       Dumper $person{$id} unless $person{$id}{name};
    next if ( $person{$id}{name} eq '. .' );

    my $pers_uri = $ROOT_URI . "person/$id";

    # here for identifying the speaker if more precise name values or IDs are
    # missing
    $rdf_txt .= "<$pers_uri> a schema:Person .\n";
    $rdf_txt .= "<$pers_uri> schema:name \"$person{$id}{name}\" .\n";
    if ( $person{$id}{bio} ) {
      $rdf_txt .= "<$pers_uri> schema:description '''$person{$id}{bio}''' .\n";
    }
    if ( $person{$id}{orcid} ) {
      my $orcid = $person{$id}{orcid};
      $rdf_txt .= "<$pers_uri> frapo:hasORCID \"$orcid\" .\n";
      $rdf_txt .= "<$pers_uri> owl:sameAs <http://orcid.org/$orcid> .\n";
    }
    foreach my $affiliation ( @{ $person{$id}{affiliations} } ) {
      $rdf_txt .=
          "<$pers_uri> schema:affiliation [ "
        . "a schema:Organization; schema:name "
        . "\"$affiliation\" ] " . " .\n";
    }
    $rdf_txt .= "\n";
  }
  return $rdf_txt;
}

sub build_event_rdf {
  my $base     = $ROOT_URI . lc($SWIB);
  my $conf_uri = "$base/conference";

  my $rdf_txt = "\n<$conf_uri> a swc:ConferenceEvent, schema:Event .\n\n";

  foreach my $sess_key ( keys %session ) {

    # skip sessions w/o presentations
    next if scalar( @{ $session{$sess_key}{presentations} } ) eq 0;

    my $sess_uri = "$base/session/$sess_key";
    $rdf_txt .= "\n<$sess_uri> a swc:SessionEvent, schema:Event .\n";
    $rdf_txt .= "<$sess_uri> schema:superEvent <$conf_uri> .\n";
    $rdf_txt .= "<$sess_uri> schema:name \"$session{$sess_key}{title}\" .\n";
    $rdf_txt .=
      "<$sess_uri> schema:startDate \"$session{$sess_key}{start_date}\" .\n";

    foreach my $contrib_key ( @{ $session{$sess_key}{presentations} } ) {
      my %contrib = %{ $abstract{$contrib_key} };

      my $contrib_uri = "$base/contribution/$contrib_key";
      $rdf_txt .= "\n<$contrib_uri> a schema:CreativeWork .\n";
      $rdf_txt .= "<$contrib_uri> schema:featuredAt <$sess_uri> .\n";
      $rdf_txt .= "<$contrib_uri> schema:name \"$contrib{title}\" .\n";
      if ( $contrib{abstract} ) {
        $rdf_txt .=
          "<$contrib_uri> schema:abstract '''$contrib{abstract}''' .\n";
      }

      foreach my $author ( @{ $contrib{authors} } ) {

        # skip authors w/o email (id)
        my $author_id = $author->{author_id} || next;

        my $author_uri = $ROOT_URI . "person/$author_id";
        $rdf_txt .= "<$contrib_uri> schema:author <$author_uri> .\n";
      }
    }
  }

  return $rdf_txt;
}

sub build_prefix_rdf {
  my $prefixes = <<'EOF';
@prefix dct: <http://purl.org/dc/terms/> .
@prefix frapo: <http://purl.org/cerif/frapo/> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix schema: <http://schema.org/> .
@prefix swc: <http://data.semanticweb.org/ns/swc/ontology#> .

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

    my $name       = $node->findvalue("./${field_prefix}_name");
    my $org_string = $node->findvalue("./${field_prefix}_organisation");
    my $orcid      = $node->findvalue("./${field_prefix}_orcid");

    # remove speaker indicator from name string
    $name =~ s/(.*?)\*/$1/;

    # one person may be affiliated to multiple organisations
    $org_string =~ s/\n/ /ms;
    my @affiliations = split( /; /, $org_string );

    # save as person (for RDF)
    $person{$id} = {
      name         => $name,
      affiliations => \@affiliations,
      orcid        => $orcid,
    };

    my %entry = (
      author_id    => $id,
      name         => $name,
      affiliations => \@affiliations,
      orcid        => $orcid,
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

  my @authors_loop;
  foreach my $author ( @{ $abstract{$abstract_id}{authors} } ) {
    my %entry = ( name => $author->{name}, );

    # author_id/speaker links if author is a speaker and has a bio
    if (  $speaker{ $author->{author_id} }
      and $speaker{ $author->{author_id} }{is_speaker} )
    {
      $entry{author_id} = $author->{author_id};
    }
    if ( $author->{orcid} ) {
      $entry{orcid} = $author->{orcid};
    }
    if ( $author->{index} ) {
      $entry{index} = $author->{index};
    }
    push( @authors_loop, \%entry );
  }
  return \@authors_loop;
}

sub mk_organisations_loop {
  my $abstract_id = shift or croak('param missing');

  my @organisations_loop;

  my %organisations = %{ $abstract{$abstract_id}{organisations} };
  if ( scalar( keys %organisations ) gt 1 ) {
    foreach my $index ( sort keys %organisations ) {
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

sub mk_url {
  my $media_type = shift or croak('param missing');
  my $url_type   = shift or croak('param missing');
  my $stub       = shift or croak('param missing');

  my $url;

  # local files are stored in /{media_type} subdir
  if ( $url_type eq 'local_file' ) {
    $stub =~ s/ /%20/;
    $url = $ROOT_URI . lc($SWIB) . "/$media_type/$stub";
  }

  if ( $url_type eq 'full_url' ) {
    $url = $stub;
  }
  return $url;
}
