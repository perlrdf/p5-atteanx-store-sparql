use v5.14;
use Test::Modern;
use Attean;
use Attean::RDF;
use AtteanX::Store::SPARQL::Plan::Triple;

package TestPlanner {
	use Moo;
	use namespace::clean;
	extends 'Attean::IDPQueryPlanner';

	sub access_plans {
		my $self	= shift;
		my $model = shift;
		my $active_graphs	= shift;
		my $pattern	= shift;
		my @vars	= $pattern->values_consuming_role('Attean::API::Variable');

		return AtteanX::Store::SPARQL::Plan::Triple->new(subject => $pattern->subject,
																		 predicate => $pattern->predicate,
																		 object => $pattern->object,
																		 in_scope_variables => [ map {$_->value} @vars],
																		 distinct => 0);
	}
};

package TestModel {
	use Moo;
	use namespace::clean;
	
	with 'Attean::API::Model';
	has 'store' => (
						 is => 'ro',
						 does => 'Attean::API::TripleStore',
						 required => 1,
						 handles => [qw(get_triples count_triples get_sparql)],
						);

	sub get_quads {
		my $self = shift;
		return $self->get_triples(@_);
	}

	sub count_quads {
		my $self = shift;
		return $self->count_triples(@_);
	}

	sub get_graphs {
		return 'nograph';
	}

};


my $p = TestPlanner->new();
isa_ok($p, 'Attean::IDPQueryPlanner');

my $store	= Attean->get_store('SPARQL')->new('endpoint_url' => iri('http://test.invalid/'));
isa_ok($store, 'AtteanX::Store::SPARQL');
my $model	= TestModel->new( store => $store );
my $t		= triple(variable('s'), iri('p'), literal('1'));
my $u		= triple(variable('s'), iri('p'), variable('o'));
my $v		= triple(variable('s'), iri('q'), blank('xyz'));
my $w		= triple(variable('a'), iri('b'), iri('c'));

subtest '1-triple BGP single variable' => sub {
	my $bgp		= Attean::Algebra::BGP->new(triples => [$u]);
	my $plan	= $p->plan_for_algebra($bgp, $model);
	does_ok($plan, 'Attean::API::Plan', '1-triple BGP');
	isa_ok($plan, 'AtteanX::Store::SPARQL::Plan::Triple');
	is($plan->plan_as_string, 'SPARQLTriple { ?s, <p>, ?o }', 'as_string gives the correct string');
# TODO: {
#		local $TODO = 'Not the correct iterator yet';
#	my $it = $plan->impl($model);
#	is(ref($it), 'CODE');
#	}

};


done_testing;
