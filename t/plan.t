use v5.14;
use Test::Modern;
use Attean;
use Attean::RDF;
use AtteanX::Model::SPARQL;
use Data::Dumper;
#use Carp::Always;

my $p = Attean::IDPQueryPlanner->new();
isa_ok($p, 'Attean::IDPQueryPlanner');

my $store	= Attean->get_store('SPARQL')->new('endpoint_url' => iri('http://test.invalid/'));
isa_ok($store, 'AtteanX::Store::SPARQL');
does_ok($store, 'Attean::API::TripleStore');
does_ok($store, 'Attean::API::CostPlanner');

my $model	= AtteanX::Model::SPARQL->new( store => $store );
isa_ok($model, 'AtteanX::Model::SPARQL');
can_ok($model, 'get_sparql');
my $graph = iri('http://example.org');
my $t		= triple(variable('s'), iri('p'), literal('1'));
my $u		= triple(variable('s'), iri('p'), variable('o'));
my $v		= triple(variable('s'), iri('q'), blank('xyz'));
my $w		= triple(variable('a'), iri('b'), iri('c'));

subtest '1-triple BGP two variables' => sub {
	my $bgp		= Attean::Algebra::BGP->new(triples => [$u]);
	my $plan	= $p->plan_for_algebra($bgp, $model, [$graph]);
	does_ok($plan, 'Attean::API::Plan', '1-triple BGP');
	isa_ok($plan, 'Attean::Plan::Quad');
	is($plan->plan_as_string, 'Quad { ?s, <p>, ?o, <http://example.org> }', 'plan_as_string gives the correct string');
};

subtest '3-triple BGP two variables' => sub {
	my $bgp		= Attean::Algebra::BGP->new(triples => [$u, $t, $v]);
	my $plan	= $p->plan_for_algebra($bgp, $model, [$graph]);
	does_ok($plan, 'Attean::API::Plan', '3-triple BGP');
	isa_ok($plan, 'AtteanX::Store::SPARQL::Plan::BGP');
	my $sp = $plan->as_string;
	is($plan->plan_as_string, 'SPARQLBGP { ?s <p> ?o ., ?s <p> "1" ., ?s <q> _:xyz . }', 'plan_as_string gives the correct string');
};

done_testing;
