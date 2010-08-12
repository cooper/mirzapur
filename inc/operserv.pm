#!/usr/bin/perl
use warnings;
use strict;
use config;
use user;
use db;
use channel;
package operserv;
my $this = {}; bless $this;
my $config = config::get();
my $users = user::new();
my $channels = channel::new();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAC';
	$this->{'nick'} = $config->{'os'}->{'nick'};
	$this->{'ident'} = $config->{'os'}->{'ident'};
	$this->{'host'} = $config->{'os'}->{'host'};
	$this->{'gecos'} = $config->{'os'}->{'gecos'};
	return $this;
}
sub handle_privmsg {
	my ($d,$main,$from,$msg) = @_;
	my @ex = split(/ /,$msg);
	my $command = lc($ex[0]);
	my $user = $users->lookup($from);
	if ($user->{'modes'} =~ m/o/) {
		if ($command eq 'mode') {
			if (defined($ex[2])) {
			my @m = split(/ /,$msg,3);
			my $modestr = $m[2];
			$this->os_mode($main,$from,$ex[1],$modestr);
			} else { $this->ss($main,$from,'mode','<channel> <modestr>'); }
		}
		elsif ($command eq 'uptime') {
			unless (defined($ex[1])) {
				$this->os_uptime($main,$from);
			} else { $this->ss($main,$from,'uptime','(no arguments)'); }
		}
		elsif ($command eq 'names') {
			if (defined($ex[1]) && !defined($ex[2])) {
				$this->os_names($main,$from,$ex[1]);
			} else { $this->ss($main,$from,'names','<channel>'); }
		}
		else { $this->us($main,$from,$command); }
	} else { $this->notice($main,$from,'Permission denied.'); }
}
sub os_names {
	my ($d,$main,$uid,$channel) = @_;
	my $chn = $channels->lookup($channel);
	if ($chn) {
		$this->notice($main,$uid,"\2Users in ".$chn->{'name'}."\2:");
		my $i = 1;
		foreach my $user (keys %{$chn->{'users'}}) {
			$user = $users->lookup($user);
			$this->notice($main,$uid,"\2$i\2. ".$user->{'nick'});
			$i++;
		}
		$this->notice($main,$uid,"\2End ".$chn->{'name'}." user list");
	} else { $this->notice($main,$uid,"Channel \2$channel\2 does not exist."); }
}
sub os_mode {
	my ($d,$main,$uid,$target,$modestr) = @_;
	my $user = $users->lookup($uid);
	my $channel = $channels->lookup($target);
	if ($channel) {
		$main->client_mode($this->{'uid'},$channel->{'name'},$modestr);
		$this->log($main,'Mode',$user->{'nick'}.' MODE '.$channel->{'name'}.' '.$modestr);
		$this->notice($main,$uid,"Mode(s) '\2$modestr\2' have been set in \2".$channel->{'name'}.".\2");
	} else { $this->notice($main,$uid,"Channel \2$target\2 does not exist."); }
}
sub os_uptime {
	my ($d,$main,$uid) = @_;
	my $user = $users->lookup($uid);
	my $seconds = (time)-($main->{'start'});
	$seconds = $main->sec2human($seconds);
	$this->notice($main,$uid,"\2Uptime\2: $seconds");
}
sub debug {
	my ($d,$main,$a,$b) = @_;
	$a = uc($a);
	$this->privmsg($main,$main->{'log'},"\2$a\2: $b");
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
