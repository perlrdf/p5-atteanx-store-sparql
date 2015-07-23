use v5.14;
use Test::Modern;
use Attean;
use Attean::RDF;
use AtteanX::Store::SPARQL::Plan::Triple;
use Data::Dumper;

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

my $p = TestPlanner->new();
isa_ok($p, 'Attean::IDPQueryPlanner');

my $store	= Attean->get_store('SPARQL')->new('endpoint_url' => iri('http://test.invalid/'));
isa_ok($store, 'AtteanX::Store::SPARQL');
my $model	= Attean::TripleModel->new( stores => { 'test' => $store } );
my $t		= triple(variable('s'), iri('p'), literal('1'));
my $u		= triple(variable('s'), iri('p'), variable('o'));
my $v		= triple(variable('s'), iri('q'), blank('xyz'));
my $w		= triple(variable('a'), iri('b'), iri('c'));

subtest '1-triple BGP two variables' => sub {
	my $bgp		= Attean::Algebra::BGP->new(triples => [$u]);
	my $plan	= $p->plan_for_algebra($bgp, $model, [iri('test')]);
	does_ok($plan, 'Attean::API::Plan', '1-triple BGP');
	isa_ok($plan, 'AtteanX::Store::SPARQL::Plan::Triple');
	is($plan->plan_as_string, 'SPARQLTriple { ?s, <p>, ?o }', 'plan_as_string gives the correct string');
};

subtest '3-triple BGP two variables' => sub {
	my $bgp		= Attean::Algebra::BGP->new(triples => [$u, $t, $v]);
	is(scalar $p->plans_for_algebra($bgp, $model, [iri('test')]), 5, "Five different plans");
	my $plan	= $p->plan_for_algebra($bgp, $model, [iri('test')]);
	does_ok($plan, 'Attean::API::Plan', '3-triple BGP');
	isa_ok($plan, 'Attean::Plan::NestedLoopJoin');
	my $sp = $plan->as_string;
	like($sp, qr/SPARQLTriple/, 'SPARQLTriple is in there');
	like($sp, qr/SPARQLTriple.+SPARQLTriple.+SPARQLTriple/s, 'SPARQLTriple is in there three times');
	like($sp, qr/NestedLoop.+NestedLoop/s, 'NestedLoop is in there twice');
	like($sp, qr/SPARQLTriple { \?s, <p>, \?o }/, 'One of the triple patterns are there');
	is($plan->plan_as_string, 'NestedLoop Join', 'plan_as_string gives the correct string');
};

done_testing;
