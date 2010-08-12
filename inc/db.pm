#!/usr/bin/perl
use strict;
use config;
use DBI;
my $config = config::get();

package db;
sub new {
	if (lc $config->{'back'} eq 'csv') {
	# support for other databases will be created in the future
	my $db = DBI->connect('DBI:CSV:f_dir=../'.$config->{'dir'}) or die("Could not allocate database\n");
	if (!-e '../'.$config->{'dir'}.'/users') {
		$db->do("CREATE TABLE users (id INT, accountname TEXT, password TEXT, hash TEXT, date INT, userhost TEXT)");
	}
	if (!-e '../'.$config->{'dir'}.'/hosts') {
		$db->do("CREATE TABLE hosts (id INT, host TEXT, date INT, setby TEXT)");
	}
	if (!-e '../'.$config->{'dir'}.'/channels') {
		$db->do("CREATE TABLE channels (channel TEXT, description TEXT, founder INT, date INT, mlock TEXT, entrymsg TEXT, ts TEXT)");
	}
	if (!-e '../'.$config->{'dir'}.'/flags') {
		$db->do("CREATE TABLE flags (channel TEXT, user INT, flags TEXT, date INT, setby INT)");
	}
	return $db;
	} else { die "DBD::CSV is the only backend support as of now. Support for other databases will be created in the future." }
}
1;
