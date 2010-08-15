#!/usr/bin/perl
use strict;
use channel;
package user;
my $this = {}; bless $this;
my $channels = channel::new();
sub new {
	return $this;
}
sub create {
	my ($d,$main,$nick,$hops,$ts,$umode,$ident,$cloak,$ip,$uid,$host,$account,$gecos) = @_;
	$host = $cloak if $host eq '*';
	$this->{$uid}->{'uid'} = $uid;
	$this->{$uid}->{'nick'} = $nick;
	$this->{$uid}->{'time'} = $ts;
	$this->{$uid}->{'ident'} = $ident; 
	$this->{$uid}->{'cloak'} = $cloak; 
	$this->{$uid}->{'ip'} = $ip;
	$this->{$uid}->{'host'} = $host;
	$this->{$uid}->{'gecos'} = $gecos;
	$this->handle_umode($uid,$umode);
	if ($main->{'ping'}) {
		my $rbl = $main->rbl($ip);
		$main->rbl_kill($uid,$rbl) if $rbl;
	}
}
sub handle_umode {
	my ($d,$uid,$modes) = @_;
	my @modes = split(undef,$modes);
	my $state;
	foreach my $mode (@modes) {
		if ($mode eq ':') { }
		if ($mode eq '-') { $state = 0; }
		if ($mode eq '+') { $state = 1; }
		if ($mode =~ m/\w/) {
			if ($state) {
				unless ($this->{$uid}->{'modes'} =~ m/$mode/) {
					$this->{$uid}->{'modes'} .= $mode;
				}
			}
			else {
				$this->{$uid}->{'modes'} =~ s/$mode//;
			}
		}
	}
}
sub nickchange {
	my ($d,$uid,$nick) = @_;
	$this->{$uid}->{'nick'} = $nick if defined $this->{$uid};
}
sub identify {
	my ($d,$uid,$id) = @_;
	$this->{$uid}->{'id'} = $id if $this->{$uid};
	return 1 if $this->{$uid};
	return;
}
sub id {
	my ($d,$uid) = @_;
	return $this->{$uid}->{'id'} if defined $this->{$uid}->{'id'};
	return;
}
sub join {
	my ($d,$user,$channel,$time) = @_;
	$channels->adduser($user,$channel,$time);
}
sub quit {
	my ($d,$user,$reason) = @_;
	delete $this->{$user};
	foreach my $channel (keys %{channel::new()}) {
		$channels->deluser($user,$channel);
	}
}
sub full {
	my ($d,$uid) = @_;
	return $this->{$uid}->{'nick'}.'!'.$this->{$uid}->{'ident'}.'!'.$this->{$uid}->{'host'};
}
sub lookup {
	my ($d,$uid) = @_;
	return $this->{$uid} if defined $this->{$uid};
	return;
}
sub fetch {
	return $this;
}
1;
