use strict;
use warnings;

use UNIVERSAL;

package Data::FormValidator::Multi::Results;
use base qw(Data::FormValidator::Results);

=head1 success

in addition to the inherited logic, success is also false if there is something in $self->{objects}

=cut

sub success {
  my $self = shift;

  if ( $self->isa('ARRAY') ) {
    return !! grep $_->success, @$self;
  } else {
    return $self->has_objects ? undef : $self->SUPER::success;
  }
}

sub to_json {
  my $self = shift;

  my $json = [];

  if ( $self->isa('ARRAY') ) {
    foreach my $results ( @$self ) {
      push @$json => $results->to_json;
    }
  } else {
    $json = $self->profile_json;
  }

  return $json;
}

sub profile_json {
  my $self = shift;

  my $json = {}; my $messages = $self->msgs;

  foreach my $field ( $self->missing, $self->invalid ) {
    $json->{$field} = $messages->{$field};
  }

  foreach my $field ( $self->objects ) {
    my $results = $self->objects->{ $field };

    if ( ref $results eq 'ARRAY' ) { # at least one element from input array has error
      my $errors = $json->{$field} = [];
      foreach my $result ( @$results ) {
#        if ( $result ) { # uhhh this returns false even when its an object?
        if ( UNIVERSAL::can( $result => 'to_json' ) ) {
          push @$errors => $result->to_json
        } else {
          push @$errors => undef;
        }
      }
    } else {
      $json->{$field} = $results->to_json;
    }
  }

  return $json;
}

=head1 has_objects

This method returns true if the results contain objects fields.

=cut

sub has_objects {
    return scalar keys %{$_[0]{objects}};

}

=head1 objects( [field] )

In list context, it returns the list of fields which are objects.
In a scalar context, it returns an hash reference which contains the objects
fields and their values.

If called with an argument, it returns the value of that C<field> if it
is objects, undef otherwise.

=cut

sub objects {
    return (wantarray ? Data::FormValidator::Results::_arrayify($_[0]{objects}{$_[1]}) : $_[0]{objects}{$_[1]})
      if (defined $_[1]);

    wantarray ? keys %{$_[0]{objects}} : $_[0]{objects};
}

1;
