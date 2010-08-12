#!/usr/bin/perl
use strict;
use user;
package channel;
my $this = {}; bless $this;
sub new {
	return $this;
}
sub adduser {
	my ($d,$user,$channel,$time) = @_;
	$channel = lc $channel;
	$this->{$channel}->{'users'}->{$user} = $time if $this->{$channel};
	$this->create($user,$channel,$time) unless $this->{$channel};
}
sub deluser {
	my ($d,$user,$channel,$time) = @_;
	$channel = lc $channel;
	delete $this->{$channel}->{'users'}->{$user} if defined $this->{$channel}->{'users'}->{$user};
	$this->check($channel);
}
sub delchannel {
	my ($d,$channel) = @_;
	$channel = lc $channel;
	delete $this->{$channel};
}
sub check {
	my ($this,$channel,$i) = (shift,shift,0);
	$channel = lc $channel;
	foreach (keys %{$this->{$channel}->{'users'}}) {
		$i++;
	}
	$this->delchannel($channel) if $i == 0;
}
sub users {
	my ($d,$channel) = @_;
	$channel = lc $channel;
	return $this->{$channel}->{'users'};
}
sub create {
	my ($d,$user,$channelname,$time) = @_;
	my $channel = lc $channelname;
	$this->{$channel}->{'name'} = lc $channelname;
	$this->{$channel}->{'time'} = $time;
	$this->{$channel}->{'users'}->{$user} = $time;
}
sub lookup {
	my ($d,$channel) = @_;
	$channel = lc $channel;
	return $this->{$channel} if defined $this->{$channel};
	return;
}
sub time {
	my ($d,$channel) = @_;
	$channel = lc $channel;
	return $this->{$channel}->{'time'} if defined $this->{$channel}->{'time'};
	return time;
}
1;
