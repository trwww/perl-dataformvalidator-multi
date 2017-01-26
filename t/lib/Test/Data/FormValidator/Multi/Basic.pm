use warnings;
use strict;

package # Hide from PAUSE
  Test::Data::FormValidator::Multi::Basic;

use base qw(Test::Data::FormValidator::Multi);
use Test::More;

sub basic : Test(2) {
  my $self = shift;

  my $data = $self->skeleton_data;

  my $dfv = $self->skeleton_validator;

  isa_ok(
    my $results = $self->{results} = $dfv->check($data)
      =>
    'Data::FormValidator::Results' => '$results'
  );

  ok(! $results->success, 'data is invalid');
}


1;
