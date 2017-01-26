use warnings;
use strict;

package # Hide from PAUSE
  Test::Data::FormValidator::Multi::Basic;

use base qw(Test::Data::FormValidator::Multi);
use Test::More;

sub basic : Test(2) {
  my $self = shift;

  my $data = {
    $self->toplevel,
    $self->meta,
    $self->timezones(
      [ 999, 'America/New_York',    'Home',  '01/01', '23:59'],
      [ 111, 'America/Los_Angeles', 'L. A.', '01/01', '20:59'],
    ),
    $self->hash_in_hash,
    $self->array_in_hash,
  };

  my $dfv = Data::FormValidator::Multi->new({
    profile     => $self->main_profile->profile,
    subprofiles => {
      timezones  => $self->timezones_profile->profile,
      meta       => $self->meta_profile->profile,
    }
  });

  isa_ok(
    my $results = $self->{results} = $dfv->check($data)
      =>
    'Data::FormValidator::Results' => '$results'
  );

  ok(! $results->success, 'data is invalid');
}


1;
