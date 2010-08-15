#!/usr/bin/perl
use strict;
use config;
use user;
use channel;
use popm;
use nickserv;
use chanserv;
use operserv;
package handlers;
my $this = {}; bless $this;
my $channels = channel::new();
my $users = user::new();
my $config = config::get();
my $nickserv = nickserv::new();
my $chanserv = chanserv::new();
my $operserv = operserv::new();
my $popm = popm::new();
my %handlers = (
	'EUID' => \&handle_euid,
	'SJOIN' => \&handle_sjoin,
	'MODE' => \&handle_mode,
	'NICK' => \&handle_nick,
	'PART' => \&handle_part,
	'QUIT' => \&handle_quit,
	'JOIN' => \&handle_join,
	'PRIVMSG' => \&handle_privmsg	
);
sub new {
	return $this;
}
sub handle {
	my ($d,$main,$data) = @_;
	my @s = split(/ /,$data);
	my $command = $s[1];
	r_ping($main,$data) if $s[0] eq 'PING';
	$handlers{$command}($main,$data) if exists $handlers{$command};
}
sub r_ping {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	$main->s_send($main->{'sid'},'PONG '.$ex[1]);
	$main->go() unless defined $main->{'ping'};
	$main->{'ping'} = time unless defined $main->{'ping'};
}
sub handle_euid {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $real = $ex[12]; $real =~ s/\://;
	$users->create($main,$ex[2],$ex[3],$ex[4],$ex[5],$ex[6],$ex[7],$ex[8],$ex[9],$ex[10],$ex[11],$real);
}
sub handle_sjoin {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my @u = split(/ /,$data,6);
	my @users = split(" ",$u[5]);
	foreach my $uid (@users) {
		$uid =~ s/\://g;
		$uid =~ s/\!//g;
		$uid =~ s/\@//g;
		$uid =~ s/\%//g;
		$uid =~ s/\+//g;
		$users->join($uid,$ex[3],$ex[2]);
	}
}
sub handle_mode {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $from = $ex[0];
	$from =~ s/\://;
	if ($ex[2] eq $from) {
		$users->handle_umode($from,$ex[3]);
	}
}
sub handle_nick {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $from = $ex[0];
	$from =~ s/\://;
	$users->nickchange($from,$ex[2]);
}
sub handle_part {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $from = $ex[0];
	$from =~ s/\://;
	$channels->deluser($from,$ex[2],time);
}
sub handle_quit {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $from = $ex[0];
	$from =~ s/\://;
	$users->quit($from,undef);
}
sub handle_join {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my $from = $ex[0];
	$from =~ s/\://;
	$users->join($from,$ex[3],$ex[2]);
}
sub handle_privmsg {
	my ($main,$data) = @_;
	my @ex = split(/ /,$data);
	my @m = split(/ /,$data,4);
	my $from = $ex[0];
	$from =~ s/\://;
	my $target = $ex[2];
	my $msg = $m[3];
	$msg =~ s/\://;
	if ($target eq $main->{'log'}) {
		$popm->handle_logmsg($main,$from,$msg);
	}
	if ($target eq $nickserv->{'uid'}) {
		$nickserv->handle_privmsg($main,$from,$msg);
	}
	elsif ($target eq $chanserv->{'uid'}) {
		$chanserv->handle_privmsg($main,$from,$msg);
	}
	elsif ($target eq $operserv->{'uid'}) {
		$operserv->handle_privmsg($main,$from,$msg);
	}
}
1;
