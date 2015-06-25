=pod

=encoding utf-8

=head1 PURPOSE

Run standard Test::Attean::TripleStore tests

=head1 AUTHOR

Kjetil Kjernsmo E<lt>kjetilk@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2015 by Kjetil Kjernsmo.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.


=cut

use strict;
use warnings;
use Test::More;
use Test::Roo;
use RDF::Trine::Model;
use RDF::Trine qw(statement iri blank literal);
use RDF::Endpoint;
use Test::LWP::UserAgent;
use HTTP::Message::PSGI;
#use Carp::Always;
use Data::Dumper;

sub create_store {
	my $self = shift;
	my %args        = @_;
	my $triples       = $args{triples} // [];
	my $model = RDF::Trine::Model->temporary_model; # For creating endpoint
	foreach my $atteantriple (@{$triples}) {
		my $s = iri($atteantriple->subject->value);
		if ($atteantriple->subject->is_blank) {
			$s = blank($atteantriple->subject->value);
		}
		my $p = iri($atteantriple->predicate->value);
		my $o = iri($atteantriple->object->value);
		if ($atteantriple->object->is_literal) {
			# difference with RDF 1.0 vs RDF 1.1 datatype semantics
			if ($atteantriple->object->datatype->value eq 'http://www.w3.org/2001/XMLSchema#string') {
				$o = literal($atteantriple->object->value, $atteantriple->object->language);
			} else {
				$o = literal($atteantriple->object->value, $atteantriple->object->language, $atteantriple->object->datatype->value);
			}
		} elsif ($atteantriple->object->is_blank) {
			$o = blank($atteantriple->object->value);
		}
		$model->add_statement(statement($s, $p, $o));
	}
	my $end = RDF::Endpoint->new($model);
	my $app = sub {
		my $env 	= shift;
		my $req 	= Plack::Request->new($env);
		my $resp	= $end->run( $req );
		return $resp->finalize;
	};
	my $useragent = Test::LWP::UserAgent->new;
	$useragent->register_psgi('localhost', $app);
	# Now, we should just have had a URL of the endpoint
	my $url = 'http://localhost:5000/sparql';
	my $store = Attean->get_store('SPARQL')->new(endpoint_url => $url,
                                                ua => $useragent
                                               );
	return $store;
}

with 'Test::Attean::TripleStore';
run_me;

done_testing;

