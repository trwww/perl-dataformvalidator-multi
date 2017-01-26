use warnings;
use strict;

package # Hide from PAUSE
  Test::Data::FormValidator::Multi::Nested;

use base qw(Test::Data::FormValidator::Multi);
use Test::More;
use Data::Dumper;

sub nested : Test(2) {
  my $self = shift;

  my $data = $self->skeleton_data;
  my $dfv  = $self->nested_validator;

  $data->{hash_in_hash}{foo}{bar} = $self->timezones(
    [ 999, 'America/New_York',    'Home',  '01/01', '23:59'],
    [ 111, 'America/Los_Angeles', 'L. A.', '01/01', '20:59'],
  );

  diag( Data::Dumper->Dump([$data], ['data']) );

  isa_ok(
    my $results = $self->{results} = $dfv->check($data)
      =>
    'Data::FormValidator::Results' => '$results'
  );

  ok(! $results->success, 'data is invalid');
}

sub nested_validator {
  my $self = shift;

  my $profile = $self->main_profile;
  $profile->add( 'hash_in_hash',
    required => 1,
  );

  my $dfv = $self->skeleton_validator;
  $dfv->{profiles}{profile} = $profile->profile;

  return $dfv;
}

1;
