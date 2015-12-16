use v5.14;
use Test::Modern;
use Attean;
use Attean::RDF;
use Attean::Plan::Quad;
use AtteanX::Store::SPARQL::Plan::BGP;

my $graph = iri('http://example.org');

my $p1 = Attean::Plan::Quad->new(subject => variable('s'), 
											predicate => iri('p'), 
											object => variable('o'), 
											graph => $graph, 
											distinct => 0);
my $p2 = Attean::Plan::Quad->new(subject => variable('a'), 
											predicate => iri('b'), 
											object => iri('c'), 
											graph => $graph, 
											distinct => 0);
my $p3 = Attean::Plan::Quad->new(subject => variable('s'), 
											predicate => iri('p'), 
											object => variable('o2'), 
											graph => $graph, 
											distinct => 0);
my $p4 = Attean::Plan::Quad->new(subject => variable('o2'), 
											predicate => iri('p'), 
											object => variable('o3'), 
											graph => $graph, 
											distinct => 0);
my $p5 = Attean::Plan::Quad->new(subject => variable('s'), 
											predicate => iri('p2'), 
											object => literal('o2'), 
											graph => $graph, 
											distinct => 0);
my $p6 = Attean::Plan::Quad->new(subject => iri('s2'), 
											predicate => variable('o3'), 
											object => literal('o4'), 
											graph => $graph, 
											distinct => 0);
my $cartfactor = 50;

is(AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(1), 100, 'Test cost function returns ok');


subtest 'Compare 1-triple BGPs with cartesian' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p2],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(2)*$cartfactor, 'Cost for BGP is OK');
	ok($bgpplan->has_cost, 'Predicate can be used');

	my $tplan1 = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1],
																		 distinct => 0
																		);
	is($tplan1->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(1), 'Cost for triple 1 is OK');
	isa_ok($tplan1, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($tplan1, 'Attean::API::Plan');

	my $tplan2 = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p2],
																		 distinct => 0
																		);
	isa_ok($tplan2, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($tplan2, 'Attean::API::Plan');
	is($tplan2->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(1), 'Cost for triple 2 is OK');
	ok($tplan1->cost + $tplan2->cost < $bgpplan->cost, 'Cost for individual triples is lower than BGP');
};

subtest '3-triple BGPs without cartesian' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p3,$p4],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(3)-2, 'Cost for BGP is OK');
};

subtest '4-triple BGPs with cartesian' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p3,$p2,$p4],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, (AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(4)-2)*$cartfactor, 'Cost for BGP is OK');
};

subtest '4-triple BGPs without cartesian, messy ordering' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p4,$p3,$p5],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(4)-3, 'Cost for BGP is OK');
};

subtest '5-triple BGPs without cartesian, messy ordering, predicate variable' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p4,$p3,$p5,$p6],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(5)-4, 'Cost for BGP is OK');
};

subtest '6-triple BGPs with cartesian, messy ordering, predicate variable' => sub {
	my $bgpplan = AtteanX::Store::SPARQL::Plan::BGP->new(children => [$p1,$p4,$p3,$p5,$p2,$p6],
																		  distinct => 0
																		 );
	isa_ok($bgpplan, 'AtteanX::Store::SPARQL::Plan::BGP');
	does_ok($bgpplan, 'Attean::API::Plan');
	is($bgpplan->cost, (AtteanX::Store::SPARQL::Plan::BGP::_cost_for_children(6)-4)*$cartfactor, 'Cost for BGP is OK');
};



done_testing;
