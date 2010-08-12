#!/usr/bin/perl
use strict;
package config;
my $this = {
	# Connecting to the network
	addr	=>	'69.164.222.215',		# address of server
	port	=>	'5000',				# port to connect on
	link	=>	'services.global',		# server name to link as
	pass	=>	'password',			# send password
	proto	=>	'shadowircd',			# protocol - "shadowircd" and "charybdis" are valid
	sid	=>	'7XZ',				# this server's SID
	name	=>	'Services',			# server description
	# Services settings
	net	=>	'cooper-dev',			# IRC network name
	log	=> 	'#services',			# services logging channel
	# Storing data
	back	=>	'csv',				# database backend (others not yet supported) default is 'csv'
	dir	=>	'db',				# storage directory
	# DNSBL
	rbl =>	[				
			'rbl.efnet.org',
			'ircbl.ahbl.org',
			'tor.dnsbl.sectoor.de',
			'tor.ahbl.org',
			'cbl.abuseat.org',
			'dnsbl.njabl.org',
			'virbl.dnsbl.bit.nl',
			'no-more-funn.moensted.dk',
			'dronebl.noderebellion.net',
			'xbl.spamhaus.org',
			'spbl.bl.winbots.org',
			'dnsbl.ahbl.org',
			'tor.sectoor.de',
			'dnsbl.swiftbl.org',
			'dnsbl.dronebl.org',
			'tor.efnet.org',
			'dnsbl.technoirc.org'
		],
	# Service clients
	ns => { # NickServ
		nick	=>	'NickServ',		# nickname
		ident	=>	'NickServ',		# user name
		host	=>	'services.global',	# host
		gecos	=>	'Nickname services'	# realname
	},
	cs => {	# ChanServ
		nick	=>	'ChanServ',		# nickname
		ident	=>	'ChanServ',		# user name
		host	=>	'services.global',	# host
		gecos	=>	'Channel services'	# realname
	},
	os => {	# OperServ
		nick	=>	'OperServ',		# nickname
		ident	=>	'OperServ',		# user name
		host	=>	'services.global',	# host
		gecos	=>	'IRC operator services'	# realname
	},
	g => {	# Global
		nick	=>	'Global',		# nickname
		ident	=>	'Global',		# user name
		host	=>	'services.global',	# host
		gecos	=>	'Network announcements'	# realname
	},
	opm => {	# Open proxy monitor
		nick	=>	'POPM'	,		# nickname
		ident	=>	'scan',			# user name
		host	=>	'services.global',	# host
		gecos	=>	'Open Proxy Monitor'	# realname
	}
};
sub new { return $this; }
sub get { return $this; }
1;
