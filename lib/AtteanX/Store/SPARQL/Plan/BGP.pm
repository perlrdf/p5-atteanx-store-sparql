use v5.14;
use warnings;

=head1 NAME

AtteanX::Store::SPARQL::Plan::BGP - Plan for efficient evaluation of SPARQL BGPs on remote endpoints

=head1 SYNOPSIS

  use v5.14;
  use AtteanX::Store::SPARQL::Plan::BGP;

=head1 DESCRIPTION

This plan class implements compiling basic graph patterns that can be
joined remotely on a SPARQL endpoint.

=item * L<Attean::Plan::Quad>

Evaluates a quad pattern against the model.

=back

=cut

package AtteanX::Store::SPARQL::Plan::BGP;

use Moo;
use Types::Standard qw(InstanceOf);
with 'Attean::API::QueryTree';

has 'algebra' => (is => 'ro', 
						isa => InstanceOf['Attean::Algebra::BGP'],
						handles => {
										_algebra_as_string => 'algebra_as_string',
										as_sparql => 'as_sparql'
									  },
					  );

with 'Attean::API::Plan';

sub plan_as_string {
 	my $self	= shift;
	return 'SPARQL' . $self->_algebra_as_string;
}


sub impl {
	my $self	= shift;
	my $model	= shift;
	my $sparql	= 'SELECT * WHERE ' . $self->as_sparql;
	return sub {
		return $model->get_sparql($sparql)
	}
}


1;
