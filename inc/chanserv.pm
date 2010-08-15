#!/usr/bin/perl
use warnings;
use strict;
use config;
use db;
use user;
package chanserv;
my $this = {}; bless $this;
my $config = config::get();
my $users = user::new();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAB';
	$this->{'nick'} = $config->{'cs'}->{'nick'};
	$this->{'ident'} = $config->{'cs'}->{'ident'};
	$this->{'host'} = $config->{'cs'}->{'host'};
	$this->{'gecos'} = $config->{'cs'}->{'gecos'};
	return $this;
}
sub handle_privmsg {
	my ($d,$main,$from,$msg) = @_;
	my @ex = split(/ /,$msg);
	my $command = lc($ex[0]);
	my $user = $users->lookup($from);
}
sub handle_fantasy {
	# TODO
}
sub ss {
	my ($d,$main,$target,$a,$b) = @_;
	$main->client_notice($this->{'uid'},$target,"Incorrect syntax for \2".uc($a).".\2");
	$main->client_notice($this->{'uid'},$target,"Syntax: \2".uc($a)."\2 $b");
}
sub us {
	my ($d,$main,$target,$a) = @_;
	$main->client_notice($this->{'uid'},$target,"Unknown command \2".uc($a)."\2.");
}
sub log {
	my ($d,$main,$a,$b) = @_;
	$a = uc($a);
	$this->privmsg($main,$main->{'log'},"\2$a\2: $b");
}
sub kick {
	my ($d,$main,$channel,$target,$msg) = @_;
	$main->client_kick($this->{'uid'},$channel,$target,$msg);
}
sub mode {
	my ($d,$main,$target,$str) = @_;
	$main->client_mode($this->{'uid'},$target,$str);
}
sub privmsg {
	my ($d,$main,$target,$msg) = @_;
	$main->client_privmsg($this->{'uid'},$target,$msg);
}
sub notice {
	my ($d,$main,$target,$msg) = @_;
	$main->client_notice($this->{'uid'},$target,$msg);
}
1;
