#!/usr/bin/perl
use warnings;
use strict;
use config;
use db;
use user;
use Digest::SHA1;

package nickserv;
my $this = {}; bless $this;
my $config = config::get();
my $users = user::new();
my $db = db::new();

sub new {
	$this->{'uid'} = $config->{'sid'}.'AAAAAA';
	$this->{'nick'} = $config->{'ns'}->{'nick'};
	$this->{'ident'} = $config->{'ns'}->{'ident'};
	$this->{'host'} = $config->{'ns'}->{'host'};
	$this->{'gecos'} = $config->{'ns'}->{'gecos'};
	return $this;
}
sub handle_privmsg {
	my ($d,$main,$from,$msg) = @_;
	my @ex = split(/ /,$msg);
	my $command = lc($ex[0]);
	my $user = $users->lookup($from);
	if ($command eq 'register') {
		if (defined($ex[1]) && !defined($ex[2])) {
			$this->ns_register($main,$user,$ex[1]);
		} else { $this->ss($main,$from,'register','<password>'); }
	}
	elsif ($command eq 'identify' || $command eq 'id') {
		if (defined($ex[1]) && !defined($ex[3])) {
			unless (defined $ex[2]) {
				$this->ns_identify($main,$user,$user->{'nick'},$ex[1]);
			} else {
				$this->ns_identify($main,$user,$ex[1],$ex[2]);
			}
		} else { $this->ss($main,$from,'register','[<account name|id>] <password>'); }
	}
	else { $this->us($main,$from,$command); }
}
sub ns_register {
	my ($d,$main,$user,$password) = @_;
	unless (length($password) < 6) {
		my $sha1 = Digest::SHA1->new();
		$sha1->add($password);
		$password = $sha1->digest();
		my $sth = $db->prepare('SELECT accountname FROM users WHERE accountname CLIKE ?');
		$sth->execute($user->{'nick'});
		my $acc = $sth->fetchrow_hashref();
		unless ($acc) {
			my $id = $this->newid();
			$db->do('INSERT INTO users VALUES (?, ?, ?, ?, ?, ?)',undef,$id,$user->{'nick'},$password,'sha1',time,$users->full($user->{'uid'}));
			$this->log($main,'Register',$user->{'nick'}.' REGISTER '.$id);
			$this->notice($main,$user->{'uid'},'You are now registered. (ID: '.$id.')');
			$users->identify($user->{'uid'},$id);
			$this->idmeta($main,$user->{'uid'},$user->{'nick'});
		} else { $this->notice($main,$user->{'uid'},"\2".$acc->{'accountname'}."\2 is already registered."); }
	} else { $this->notice($main,$user->{'uid'},'Your password must be at least 6 characters long.'); }
}
sub ns_identify {
	my ($d,$main,$user,$account,$password) = @_;
	my $sha1 = Digest::SHA1->new();
	$sha1->add($password);
	$password = $sha1->digest();
	my $sth;
	unless ($account =~ m/^\d/) {
		$sth = $db->prepare('SELECT * FROM users WHERE accountname CLIKE ?');
	} else {
		$sth = $db->prepare('SELECT * FROM users WHERE id = ?');
	}
	$sth->execute($account);
	my $acc = $sth->fetchrow_hashref();
	if ($acc) {
		if ($password eq $acc->{'password'}) {
		$users->identify($user->{'uid'},$acc->{'id'});
		$this->idmeta($main,$user->{'uid'},$acc->{'accountname'});
		$this->notice($main,$user->{'uid'},"You are now identified as \2".$acc->{'accountname'}."\2.");
		} else { $this->notice($main,$user->{'uid'},"Password incorrect."); }
	} else { $this->notice($main,$user->{'uid'},"\2$account\2 is not registered."); }
	
}
sub newid {
	my $d = shift;
	my $sth = $db->prepare('SELECT * FROM ids WHERE type CLIKE ?');
	$sth->execute('user');
	my $id = $sth->fetchrow_hashref();
	if ($id) {
		my $new = $id->{'id'}+1;
		$db->do('UPDATE ids SET id = ? WHERE TYPE = ?',undef,$new,'user');
		return $new;
	} else {
		$db->do('INSERT INTO ids VALUES (?, ?)',undef,'user','0');
		return 0;
	}
}
sub idmeta {
	my ($d,$main,$uid,$acc) = @_;
	$main->s_send($main->{'sid'},'ENCAP * SU '.$uid.' '.$acc);
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
