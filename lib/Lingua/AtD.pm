#
# This file is part of Lingua-AtD
#
# This software is copyright (c) 2011 by David L. Day.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
package Lingua::AtD;
{
  $Lingua::AtD::VERSION = '1.113000';
}
use strict;
use warnings;
use Carp;
use Class::Std;
use LWP::UserAgent;
use Lingua::AtD::Results;
use Lingua::AtD::Scores;
use Lingua::AtD::Exceptions;
use URI;

# ABSTRACT: Provides an OO wrapper for After the Deadline grammar and spelling service.

{

    # Attributes
    my %api_key_of :
      ATTR( :init_arg<api_key> :get<api_key> :default<'Lingua-AtD'> );
    my %service_host_of :
      ATTR( :init_arg<host>    :get<service_host> :default<'service.afterthedeadline.com'> );
    my %service_port_of :
      ATTR( :init_arg<port>    :get<service_port> :default<80> );
    my %service_url_of : ATTR( :get<service_url> );

    sub START {
        my ( $self, $ident, $arg_ref ) = @_;

        # Construct the URL
        $service_url_of{$ident} =
            'http://'
          . $service_host_of{$ident} . ':'
          . $service_port_of{$ident} . '/';

        return;
    }

    sub _atd : PRIVATE {
        my ( $self, $verb, $arg_ref ) = @_;
        my $ident = ident($self);
        my $url   = $service_url_of{$ident} . $verb;
        my $ua    = LWP::UserAgent->new();
        $ua->agent( 'Lingua::AtD/' . $Lingua::AtD::VERSION );

        my $response = $ua->post( $url, Content => [ %{$arg_ref} ] );
        if ( $response->is_error() ) {
            Lingua::AtD::HTTPException->throw(
                http_status => $response->status_line,
                service_url => $url,
            );
        }

        return $response->content;
    }

    sub check_document {
        my ( $self, $text ) = @_;
        my $ident = ident($self);
        my $raw_response =
          $self->_atd( 'checkDocument',
            { key => $api_key_of{$ident}, data => $text } );
        return Lingua::AtD::Results->new( { xml => $raw_response } );
    }

    sub check_grammar {
        my ( $self, $text ) = @_;
        my $ident = ident($self);
        my $raw_response =
          $self->_atd( 'checkGrammar',
            { key => $api_key_of{$ident}, data => $text } );
        return Lingua::AtD::Results->new( { xml => $raw_response } );
    }

    sub stats {
        my ( $self, $text ) = @_;
        my $ident = ident($self);
        my $raw_response =
          $self->_atd( 'stats', { key => $api_key_of{$ident}, data => $text } );
        return Lingua::AtD::Scores->new( { xml => $raw_response } );
    }
}

1;    # Magic true value required at end of module


=pod

=head1 NAME

Lingua::AtD - Provides an OO wrapper for After the Deadline grammar and spelling service.

=head1 VERSION

version 1.113000

=head1 SYNOPSIS

    use Lingua::AtD;
    
    # Create a new service proxy
    my $atd = Lingua::AtD->new( {
        host => 'service.afterthedeadline.com',
        port => 80
    });

    # Run spelling and grammar checks. Returns a Lingua::AtD::Response object.
    my $atd_response = $atd->check_document('Text to check.');
    # Loop through reported document errors.
    foreach my $atd_error ($atd_response->get_errors()) {
        # Do something with...
        print "Error string: ", $atd_error->get_string(), "\n";
    }
    
    # Run only grammar checks. Essentially the same as 
    # check_document(), sans spell-check.
    my $atd_response = $atd->check_grammar('Text to check.');
    # Loop through reported document errors.
    foreach my $atd_error ($atd_response->get_errors()) {
        # Do something with...
        print "Error string: ", $atd_error->get_string(), "\n";
    }
    
    # Get statistics on a document. Returns a Lingua::AtD::Scores object.
    my $atd_scores = $atd->stats('Text to check.');
    # Loop through reported document errors.
    foreach my $atd_metric ($atd_scores->get_metrics()) {
        # Do something with...
        print $atd_metric->get_type(), "/", $atd_metric->get_key(), 
            " = ", $atd_metric->get_value(), "\n";
    }

=head1 DESCRIPTION

Lingua::AtD provides an OO-style interface for After the Deadline's grammar and spell checking services.

=head1 METHODS

=head2 new

This constructor takes three arguments, all optional. The sample below shows the defaults.

    $atd = Lingua::AtD->new({
        api_key => 'Lingua-AtD',
        host    => 'service.afterthedeadline.com',
        port    => 80
    });

=over 4

=item api_key

API key used to access the service. Defaults to this package's name: I<Lingua-AtD>. Please consider creating your own. See the L<API Documentation|http://www.afterthedeadline.com/api.slp> for requirements. The default will work, and so far as I know will cause no problems.

=item host

Host for the AtD service. Defaults to the public host: I<service.afterthedeadline.com>. AtD's software is open source, and it's entirely possible to download and set up your own private AtD service. See the L<AtD Project website|http://open.afterthedeadline.com/> for details.

=item port

Port for the AtD service. Defaults to the standard http port: I<80>. AtD's software is open source, and it's entirely possible to download and set up your own private AtD service. See the L<AtD Project website|http://open.afterthedeadline.com/> for details.

=back

=head2 get_api_key

    $atd->get_api_key();

Returns the API Key used to access the AtD service.

=head2 get_host

    $atd->get_host();

Returns the host of the AtD service.

=head2 get_port

    $atd->get_port();

Returns the port of the AtD service.

=head2 get_service_url

    $atd->get_service();

Returns a formatted URL for the AtD service.

=head2 check_document

    $atd_results = $atd->check_document('Some text stringg in badd nneed of prufreding.');

Invokes the document check service for some string of text and return a L<Lingua::AtD::Results> object.

From the L<API Documentation|http://www.afterthedeadline.com/api.slp>: I<Checks a document and returns errors and suggestions>

=head2 check_grammar

    $atd_results = $atd->check_grammar('Some text stringg in badd nneed of prufreding.');

Invokes the grammar check service for some string of text and return a L<Lingua::AtD::Results> object. This differs from I<check_document> in that it only checks grammar and style, not spelling.

From the L<API Documentation|http://www.afterthedeadline.com/api.slp>: I<Checks a document (sans spelling) returns errors and suggestions>

=head2 stats

    $atd_scores = $atd->stats('Some text stringg in badd nneed of prufreding.');

Invokes the stats service for some string of text and return a L<Lingua::AtD::Scores> object. This differs from I<check_document> in that it only checks grammar and style, not spelling.

From the L<API Documentation|http://www.afterthedeadline.com/api.slp>: I<Returns statistics about the writing quality of a document>

=head1 BUGS

No known bugs.

=head1 IRONY

Wouldn't it be kind of funny if I had a ton of spelling/grammar/style errors in my documentation? Yeah, it would. And I bet there are. Shame on me for not running my documentation through my own module.

=head1 SEE ALSO

=for :list * L<Your::Module>
* L<Your::Package>

See the L<API Documentation|http://www.afterthedeadline.com/api.slp> at After the Deadline's website.

B<NB:> In the L<API Documentation|http://www.afterthedeadline.com/api.slp>, there is a fourth service called B</info.slp>. I do not plan to implement this. Each Lingua::AtD::Error supplies an informative URL when one is available. I see no reason to call this independently, but feel free to submit a patch if you find a reason.

=head1 AUTHOR

David L. Day <dday376@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by David L. Day.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__
