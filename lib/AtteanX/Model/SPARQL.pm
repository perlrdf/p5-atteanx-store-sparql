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

1;

__END__

=pod

=encoding utf-8

=head1 NAME

AtteanX::Model::SPARQL - Attean SPARQL Model

=head1 SYNOPSIS

  my $store = Attean->get_store('SPARQL')->new(endpoint_url => $url);
  my $model = AtteanX::Model::SPARQL->new( store => $store );

=head1 DESCRIPTION

This model is in practice a thin wrapper around the underlying SPARQL
store, that adds facilities only to allow quering and planning with
quad semantics.

It consumes L<Attean::API::Model> and L<Attean::API::CostPlanner> and
adds no new methods or attributes.

=head1 OTHER DETAILS

For author, copyright and other details, see L<AtteanX::Store::SPARQL>.


=cut

