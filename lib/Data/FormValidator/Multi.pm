use warnings;
use strict;

use Data::FormValidator::Multi::Results;

package Data::FormValidator::Multi;
use base qw(Data::FormValidator);

sub check {
  my($self, $datas, $profile) = @_;

  my $results = [];
  if ( ref $datas eq 'ARRAY' ) {
    foreach my $data ( @$datas ) {
      my $element_results = (ref $self)->new->check( $data, $self->{profiles}{profile} );
      push @$results => $element_results;
    }
  } else {
    $results = $self->SUPER::check( $datas, $self->{profiles}{profile} || $profile );
  }

  bless $results => 'Data::FormValidator::Multi::Results';

  $self->check_nested( $results ) unless ref $datas eq 'ARRAY';

  return $results;
}

=head2 check_nested

=cut

sub check_nested {
  my($self, $results) = @_;

  my $profiles = $self->{profiles}{subprofiles} || {};
  foreach my $field ( keys %$profiles ) {
    $self->check_nested_for( $field => $results );
  }
}

sub check_nested_for {
  my($self, $field, $results) = @_;

  my $profile = $self->{profiles}{subprofiles}{$field};

  if ( $profile->{subprofiles} ) {
    $self->has_nested_profiles( $profile, $field, $results );
  } else {
    $self->no_nested_profiles( $profile, $field, $results );
  }

}

sub has_nested_profiles {
  my($self, $profile, $field, $results) = @_;

  die 'nested profiles unimplemented';
}

sub no_nested_profiles {
  my($self, $profile, $field, $results) = @_;

  if ( my $datas = $results->valid($field) ) { # data can be an array or hash

    if ( ref $datas eq 'HASH' ) {
      $self->handle_hash_input( $profile, $field, $results, $datas );
    } elsif ( ref $datas eq 'ARRAY' ) {
      $self->handle_array_input( $profile, $field, $results, $datas );
    } else {
      die 'dont know how to process $datas';
    }

  }

}

sub handle_hash_input {
  my($self, $profile, $field, $results, $datas) = @_;

  my $nested_results = Data::FormValidator::Multi::Results->new( $profile, $datas );

  if ( ! $nested_results->success ) {
    $self->move_from_valid_to_objects( $field, $results, $nested_results );
  }
}

sub handle_array_input {
  my($self, $profile, $field, $results, $datas) = @_;

# $DB::single = 1;

  # set up some local state to handle error condition
  my $error = {};
  my $errors = $error->{errors} = [];
  $error->{total} = $error->{count} = 0;

  foreach my $data ( @$datas ) {
    $error->{total}++;
    push @$errors => undef; # array element gets replaced if there is an error

    my $nested_results = Data::FormValidator::Multi::Results->new( $profile, $data );

    if ( ! $nested_results->success ) {
      $error->{count}++;
      pop @$errors;
      push @$errors => $nested_results;
    }
  }

  $self->move_from_valid_to_objects( $field, $results, $errors ) if $error->{count};
}

sub move_from_valid_to_objects {
  my($self, $field, $results, $field_results) = @_;

  delete $results->{valid}{$field};

  $results->{objects} ||= {};
  $results->{objects}{$field} = $field_results;
}

1;
