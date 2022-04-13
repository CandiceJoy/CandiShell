#!/usr/bin/perl
use warnings;
use strict;

my $dotGitUrlPattern = "\\s*url\\s?=\\s?(.*)";
my $httpPattern = "http(?:s)?://(.*?)/(.*?)/(.*)";

my @domains = ("github.com","candicejoy.com");
my $get = `cat ./.git/config |grep "url"`;
#my $get = `cat /Users/candice/CandiShell/.git/config |grep "url"`;
my $url;

if( $get =~ /$dotGitUrlPattern/i )
{
	$url = $1;
	print("URL: $url\n");
}
else
{
	print("Cannot find URL\n");
	print($get."\n");
	exit 1;
}

my $domain;
my $username;
my $repo;

if( $url =~ /$httpPattern/i )
{
	$domain = $1;
	$username = $2;
	$repo = $3;
}

print("Domain: $domain\nUsername: $username\nRepo: $repo\n");

my $sshUrl = "git\@$domain:$username/$repo";

print("New URL: $sshUrl\n");

`git remote set-url origin "$sshUrl"`;