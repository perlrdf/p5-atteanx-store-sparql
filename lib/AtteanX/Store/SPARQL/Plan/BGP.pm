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
use Types::Standard qw(ArrayRef InstanceOf);
with 'Attean::API::QueryTree',
     'Attean::API::Plan',
     'Attean::API::UnionScopeVariablesPlan';

sub plan_as_string {
 	my $self	= shift;
	return 'SPARQLBGP';
}

sub cost {
	my $self = shift;
	my @kids = @{ $self->children };
	my $base = 10 * scalar @kids;
	my $result = $base;
	my %quads_with_joins;
	foreach my $kid (@kids) {
		my @vars	= @{ $kid->in_scope_variables };
		foreach my $v (@vars) {
			$quads_with_joins{$v}++;
		}
	}
	foreach my $sub (values(%quads_with_joins)) {
		$result -= ($sub - 1)
	}
	return $result;
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
