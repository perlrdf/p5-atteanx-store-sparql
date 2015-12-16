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
with 'Attean::API::QueryTree',
     'Attean::API::Plan',
     'Attean::API::UnionScopeVariablesPlan';

sub add_children {
	my $self = shift;
	push(@{$self->children}, @_);
}

sub plan_as_string {
 	my $self	= shift;
	return 'SPARQLBGP';
}

sub cost {
	# This code is admittedly not very pretty. Advices on how to
	# simplify are welcome, pull requests even more so
	my $self = shift;
	my @kids = @{ $self->children };
	my $nokids = scalar @kids;
	my $result = _cost_for_children($nokids);
	my %variables_in_quads;
	my $i = 0;
	foreach my $kid (@kids) {
		# First create a hash with which quads have which variables
		my @vars	= @{ $kid->in_scope_variables };
		foreach my $v (@vars) {
			push(@{$variables_in_quads{$v}}, $i);
		}
		$i++;
	}
	my %quads_with_joins;
	my $maxcommon = 0;
	foreach my $quads (values(%variables_in_quads)) {
		my $count = scalar @{$quads};
		$result -= ($count - 1); # Lower the cost slightly for each shared variable
		if ($count > 1) {
			foreach my $quadno (@{$quads}) {
				$quads_with_joins{$quadno} = 1; # The keys should now be an array with all quads that share a variable
			}
		}
		$maxcommon = $count if ($maxcommon < $count);
	}
	return $result if $maxcommon == $nokids; # as many shared variables as quads
	my @quads_with_joins = sort keys %quads_with_joins;
	return 50 * $result unless (@quads_with_joins);
	# Now look for cartesians
	my $cartesian = 1; # 1 means no cartesians, provide factor below if it is
	for (my $j = 0; $j < $nokids; $j++) {
		if ($j != $quads_with_joins[$j]) {
			$cartesian = 50;
			last;
		}
	}
	return $result * $cartesian;
}

sub has_cost { return 1 }

# A function to estimate a cost of just the number of children
sub _cost_for_children  {
	my $nokids = shift;
	return int(60 + 50*exp(-$nokids/5))
}
sub impl {
	my $self	= shift;
	my $model	= shift;
	my $sparql	= 'SELECT * WHERE ' . $self->as_sparql;
	return sub {
		return $model->get_sparql($sparql)
	}
}

# TODO: This is cutnpaste from Attean::Algebra::BGP, any way to not do that?
sub _as_sparql {
	my $self	= shift;
	my %args	= @_;
	my $level	= $args{level} // 0;
	my $sp		= $args{indent} // '    ';
	my $indent	= $sp x $level;

	return "${indent}{\n"
	  . join('', map { $indent . $sp . $_->_as_sparql( %args, level => $level+1 ) } @{ $self->quads }) . "${indent}}\n";
}

1;
