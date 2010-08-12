#!/usr/bin/perl
use warnings;
use strict;
use config;
use db;
package nickserv;
my $this = {}; bless $this;
my $config = config::get();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAA';
	$this->{'nick'} = $config->{'ns'}->{'nick'};
	$this->{'ident'} = $config->{'ns'}->{'ident'};
	$this->{'host'} = $config->{'ns'}->{'host'};
	$this->{'gecos'} = $config->{'ns'}->{'gecos'};
	return $this;
}

1;
