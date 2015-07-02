use v5.14;
use warnings;

=head1 NAME

Attean::Plan - Representation of SPARQL query plan operators

=head1 VERSION

This document describes Attean::Plan version 0.006

=head1 SYNOPSIS

  use v5.14;
  use Attean;

=head1 DESCRIPTION

This is a utility package that defines all the Attean query plan classes
in the Attean::Plan namespace:

=over 4

=cut

use Attean::API::Query;

=item * L<AtteanX::Store::SPARQL::Plan::Triple>

Evaluates a quad pattern against the model.

=cut

package AtteanX::Store::SPARQL::Plan::Triple;
use Moo;
use Types::Standard qw(ConsumerOf ArrayRef);

has 'subject'	=> (is => 'ro', required => 1);
has 'predicate'	=> (is => 'ro', required => 1);
has 'object'	=> (is => 'ro', required => 1);
#	has 'graph'		=> (is => 'ro', required => 1);

with 'Attean::API::Plan', 'Attean::API::NullaryQueryTree';
with 'Attean::API::TriplePattern';

sub plan_as_string {
	my $self	= shift;
	my @nodes	= $self->values;
	my @strings;
	foreach my $t (@nodes) {
		if (ref($t) eq 'ARRAY') {
			my @tstrings	= map { $_->ntriples_string } @$t;
			if (scalar(@tstrings) == 1) {
				push(@strings, @tstrings);
			} else {
				push(@strings, '[' . join(', ', @tstrings) . ']');
			}
		} elsif ($t->does('Attean::API::TermOrVariable')) {
			push(@strings, $t->ntriples_string);
		} else {
			use Data::Dumper;
			die "Unrecognized node in quad pattern: " . Dumper($t);
		}
	}
	return sprintf('SPARQLTriple { %s }', join(', ', @strings));
}

sub impl {
	my $self	= shift;
	my $model	= shift;
	my @values	= $self->values;
	my $tripleiter = $model->get_triples( @values );
	return sub {
		
	}
}

1;
