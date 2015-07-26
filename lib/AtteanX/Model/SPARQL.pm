package AtteanX::Model::SPARQL;

use v5.14;
use warnings;

use Moo;
use Types::Standard qw(InstanceOf);
use Scalar::Util qw(reftype);
use namespace::clean;

has 'store'    => (
						 is => 'ro',
						 isa => InstanceOf['AtteanX::Store::SPARQL'],
						 required => 1,
						 handles => { size => 'size' ,
										  get_quads => 'get_triples',
										  count_quads => 'count_triples',
										  cost_for_plan => 'cost_for_plan',
										  get_sparql => 'get_sparql',
										  plans_for_algebra => 'plans_for_algebra'
										}
						);


with 'Attean::API::Model', 'Attean::API::CostPlanner';

sub get_graphs {
	return Attean::ListIterator->new();
}


=item C<< get_quads ( $subject, $predicate, $object, $graph ) >>

Returns an L<Attean::API::Iterator> for quads in the model that match the
supplied C<< $subject >>, C<< $predicate >>, C<< $object >>, and C<< $graph >>.
Any of these terms may be undefined or a L<Attean::API::Variable> object, in
which case that term will be considered as a wildcard for the purposes of
matching.

The returned iterator conforms to both L<Attean::API::Iterator> and
L<Attean::API::QuadIterator>.

=cut


1;
