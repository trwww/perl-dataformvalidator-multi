#!/usr/bin/env perl

use FindBin;
use lib "$FindBin::Bin/lib";

use Test::Data::FormValidator::Multi;

# run all the test methods
Test::Data::FormValidator::Multi->runtests;
