use utf8;
use v5.36;
package WebService::USNationalParkService;

use Mojo::UserAgent;

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

WebService::USNationalParkService - Interface to the US National Park Service API

=head1 SYNOPSIS

	use WebService::USNationalParkService;

=head1 DESCRIPTION

https://www.nps.gov/subjects/developer/get-started.htm

=over 4

=item new( API_TOKEN )

Creates a new
Get your API token at L<https://www.nps.gov/subjects/developer/get-started.htm>.


=cut

sub new ($class, $api_token) {
	my $ua = Mojo::UserAgent->new;
	$ua->on( start => sub ($ua, $tx) {
		$tx->req->headers->header( 'X-Api-Key' => $api_token );
		} );

	bless { ua => $ua }, $class;
	}

=item base_url

Returns C<https://developer.nps.gov/api/v1>.

=cut

sub base_url ($c) {
	'https://developer.nps.gov/api/v1'
	}

=back

=cut


sub _get ( $self, @args ) {
	$self->_ua->get( @args );
	}

sub _ua ( $self ) { $self->{ua} }

=head2 Methods

=over 4

=item * check_rate_limit()

Returns a hash reference with two keys: C<limit> and C<remaining>. The
first is the highest limit for your account, and the second is the
number of request immediately available. The number of request
immediately available is reset on a rolling hourly basis. That means
that any request you made an hour or more ago does not count against
the current rate limit.

=cut

sub check_rate_limit ($self) {
	my $tx = $self->_get( $self->base_url );

	return {
		'limit'     => 0,
		'remaining' => 0,
	} unless $tx->res->code eq '404';

	my %hash =
		map { s/\Ax-ratelimit-//r => $tx->res->headers->header($_) }
		qw(x-ratelimit-limit x-ratelimit-remaining);

	return \%hash;
	}


=back

=head1 TO DO


=head1 SEE ALSO

=over 4

=item * L<https://www.nps.gov/subjects/developer/index.htm>

=item * L<https://www.nps.gov/subjects/developer/get-started.htm>

=item * L<https://github.com/nationalparkservice>

=back

=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/webservice-usnationalparkservice

=head1 AUTHOR

brian d foy, C<< <brian d foy> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2023-2024, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

1;
