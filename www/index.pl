#!/usr/bin/perl -w
use strict;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use Base;

my $base = Base->factory();
$base->render();
