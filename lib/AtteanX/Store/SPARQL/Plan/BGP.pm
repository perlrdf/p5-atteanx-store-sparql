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

=over 4

=cut

use Attean::API::Query;

=item * L<Attean::Plan::Quad>

Evaluates a quad pattern against the model.

=cut

package AtteanX::Store::SPARQL::Plan::BGP;

use Moo;
use Types::Standard qw(ConsumerOf ArrayRef);

has 'triples' => (is => 'ro', isa => ArrayRef[ConsumerOf['Attean::API::TriplePattern']], default => sub { [] });

with 'Attean::API::Plan';

# sub plan_as_string {
# 	my $self	= shift;
# 	my @nodes	= $self->values;
# 	my @strings;
# 	foreach my $t (@nodes) {
# 		if (ref($t) eq 'ARRAY') {
# 			my @tstrings	= map { $_->ntriples_string } @$t;
# 			if (scalar(@tstrings) == 1) {
# 				push(@strings, @tstrings);
# 			} else {
# 				push(@strings, '[' . join(', ', @tstrings) . ']');
# 			}
# 		} elsif ($t->does('Attean::API::TermOrVariable')) {
# 			push(@strings, $t->ntriples_string);
# 		} else {
# 			use Data::Dumper;
# 			die "Unrecognized node in quad pattern: " . Dumper($t);
# 		}
# 	}
# 	return sprintf('Quad { %s }', join(', ', @strings));
# }

sub impl {
	my $self	= shift;
	my $model	= shift;
	my $sparql	= 'SELECT * WHERE {';
	foreach my $t ($self->triples) {
		$sparql .= "\n\t" . $t->as_sparql;
	}
	$sparql .= "\n}";
	return sub {
		return $model->get_sparql($sparql)
	}
}

# sub as_sparql {
# 	my $self	= shift;
# 	my %args	= @_;
# 	my $level	= $args{level} // 0;
# 	my $sp		= $args{indent} // '    ';
# 		my $indent	= $sp x $level;
	
# 	return "${indent}{\n"
# 	  . join('', map { $indent . $sp . $_->as_sparql( %args, level => $level+1 ) } @{ $self->triples })
# 		 . "${indent}}\n";
# }

