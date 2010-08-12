#!/usr/bin/perl
use strict;
use config;
use db;
use user;
use operserv;
package popm;
my $this = {}; bless $this;
my $config = config::get();
my $operserv = operserv::new();
my $users = user::new() or die;
sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAD';
	$this->{'nick'} = $config->{'opm'}->{'nick'};
	$this->{'ident'} = $config->{'opm'}->{'ident'};
	$this->{'host'} = $config->{'opm'}->{'host'};
	$this->{'gecos'} = $config->{'opm'}->{'gecos'};
	return $this;
}
sub fetch {
	return $this;
}
sub check {
	my ($d,$ip,$i) = (shift,shift,1);
	my @rbl;
	my @sec = split(/\./,$ip);
	foreach (@sec) {
		$rbl[$i] = $_;
		$i++;
	}
	my $res = $rbl[4].'.'.$rbl[3].'.'.$rbl[2].'.'.$rbl[1];

	foreach (@{$config->{'rbl'}}) {
		print "checking $ip in $_";
		if (gethostbyname($res.'.'.$_)) {
			print ".. YES\n";
			return $_;
		}
		else { print " ..no\n"; }
	}
	return;
}
sub checkall {
	my $d = shift;
	my $main = shift;
	foreach my $user (keys %$users) {
		$user = $users->lookup($user);
		bless $user;
		my $rbl = $this->check($user->{'ip'});
		if ($rbl) {
			$this->kill($main,$user->{'uid'},$rbl);
		}
	}
	$this->log($main,'Global scan','Scan complete.');
}
sub handle_logmsg {
	my ($d,$main,$from,$msg) = @_;
	my @ex = split(/ /,$msg);
	if (uc($msg) =~ m/^POPM/) {
		my $user = $users->lookup($from);
		if ($user->{'modes'} =~ m/o/) {
			if (lc($ex[1]) eq 'scan') {
				if (defined $ex[2] && !defined $ex[3]) {
					$this->log($main,'Scan','Scanning '.$ex[2]);
					my @rbl; my $i = 1;
					my @sec = split(/\./,$ex[2]);
					foreach (@sec) {
						$rbl[$i] = $_;
						$i++;
					}
					my $res = $rbl[4].'.'.$rbl[3].'.'.$rbl[2].'.'.$rbl[1];

					foreach (@{$config->{'rbl'}}) {
						if (gethostbyname($res.'.'.$_)) {
							$this->log($main,'Scan',$ex[2]." \2is\2 listed in $_");
						}
						else { $this->log($main,'Scan',$ex[2].' is not listed in '.$_); }
					}
					$this->log($main,'Scan','Scan complete');
				} else { $this->log($main,'Syntax','SCAN <ip>'); }
			}
		} else { $this->log($main,'Permission denied','You are not an IRC operator.'); }
		if (lc($ex[1]) eq 'scanall') {
			unless (defined $ex[2]) {
				$this->log($main,'Global scan','Scannning all users on the network. The more listings you have configured, the longer this will take.');
				$this->checkall($main);
			} else { $this->log($main,'Syntax','SCANALL (no parameters)'); }
		}
	}
}
sub kill {
	my ($d,$main,$user,$rbl) = @_;
	$user = $users->lookup($user);
	$this->log($main,'Scan',$user->{'nick'}.'\'s IP, '.$user->{'ip'}.', is listed in '.$rbl);
	$main->s_send($this->{'uid'},'KILL '.$user->{'nick'}.' :'.$config->{'link'}.'!'.$config->{'opm'}->{'nick'}.' (Your host is listed in '.$rbl.')');
	$users->quit($user->{'uid'},'Killed by POPM');
}
sub log {
	my ($d,$main,$a,$b) = @_;
	$a = uc($a);
	$this->privmsg($main,$main->{'log'},"\2$a\2: $b");
}
sub privmsg {
	my ($d,$main,$target,$msg) = @_;
	$main->client_privmsg($this->{'uid'},$target,$msg);
}
1;
