#!/usr/bin/perl
use warnings;
use strict;
use config;
use db;
package chanserv;
my $this = {}; bless $this;
my $config = config::get();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAB';
	$this->{'nick'} = $config->{'cs'}->{'nick'};
	$this->{'ident'} = $config->{'cs'}->{'ident'};
	$this->{'host'} = $config->{'cs'}->{'host'};
	$this->{'gecos'} = $config->{'cs'}->{'gecos'};
	return $this;
}


1;
