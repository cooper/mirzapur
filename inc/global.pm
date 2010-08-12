#!/usr/bin/perl
use warnings;
use strict;
use config;
use user;

package global;
my $this = {}; bless $this;
my $config = config::get();
my $users = user::new();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAE';
	$this->{'nick'} = $config->{'g'}->{'nick'};
	$this->{'ident'} = $config->{'g'}->{'ident'};
	$this->{'host'} = $config->{'g'}->{'host'};
	$this->{'gecos'} = $config->{'g'}->{'gecos'};
	return $this;
}
sub global_send {
	my ($d,$main,$uid,$msg) = @_;
	my $u = $users->lookup($uid);
	foreach my $user (keys %$users) {
		$this->notice($main,$user,'Network notice from '.$u->{'nick'}.': '.$msg);
	}
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
