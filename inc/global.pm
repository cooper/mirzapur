#!/usr/bin/perl
use warnings;
use strict;
use config;
use user;
use db;
package global;
my $this = {}; bless $this;
my $config = config::get();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAE';
	$this->{'nick'} = $config->{'g'}->{'nick'};
	$this->{'ident'} = $config->{'g'}->{'ident'};
	$this->{'host'} = $config->{'g'}->{'host'};
	$this->{'gecos'} = $config->{'g'}->{'gecos'};
	return $this;
}
