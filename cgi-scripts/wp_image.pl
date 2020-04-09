#!/usr/bin/perl

use strict;
use utf8;
use CGI qw(:standard);
use XMLRPC::Lite;
use IO::Socket::SSL;
use MIME::Base64 ();
use URI::Escape;
use Data::Dumper;

my ($buf,$contents);
my $pictureid;
my @categories;
my $pictureurl;

# settings
my $username = "perl";
my $password = &getpasswd;
my $server = "http://telepoesis.net/poemario/xmlrpc.php";
my $htmlpost = "real content tester";

print CGI::header();
my %cgivars= &getcgivars();

#open my $fh, '>', '/home/telepoes/public_html/unborn/images/adium.png' or die $!;
#binmode $fh;
#print $fh $cgivars{"image_dec"};
#close $fh;
#$cgivars{"txt"} = "nunof";
#exit;

my $publishdate = time;
my $wpdir = use_category($cgivars{'wpd'}, $password);

my $res = XMLRPC::Lite
->proxy($server)
->call('wp.uploadFile', 1, $username, $password,
{ name => "imagem_$publishdate.png", type => 'image/png', bits => $cgivars{'image_dec'}, overwrite => "true" } )
->result;

if (defined ($res)) {
	$pictureid = $res->{id};
	$pictureurl = $res->{url};
	print ". picture uploaded with id $pictureid\n";
} 
else {
	print " .. uploading picture failed: $!";
}

my $res = XMLRPC::Lite
->proxy($server)
->call('wp.newPost', 1, $username, $password,
{
	post_status  => "publish",
	post_content => "$cgivars{'txt'}\n\nfull image in $pictureurl",
    post_title => "poemario img $publishdate\n\npor $cgivars{'pu'}",
    #custom_fields => [
		#	{ "key" => "_thumbnail_id", "value" => $pictureid },
		#	{ "key" => "_thumbnail_url", "value" => $pictureurl }
		#]
	post_thumbnail => $pictureid,
    categories  => ($wpdir)
}, 1)->result;

if (defined ($res)) {
	print ". posted id $res to picture id $pictureid\n";
} 
else {
	print ".. posting article with id $res failed: $!";
}

sub getcgivars {

	my %in = ();
	my $req_method = $ENV{'REQUEST_METHOD'};
	#return %in unless($req_method eq 'POST');
  	my @params = param();
  	my $pn = "";
  	foreach $pn ( @params ) { print "$pn \n"; }

	my $pimg = uri_unescape(param("img"));
	my $ptxt = uri_unescape(param("txt"));
	my $pu = uri_unescape(param("poem_user"));
	my $wpd = uri_unescape(param("wp_dir"));

	return () unless (defined($ptxt) && length($ptxt) > 0);
	return () unless (defined($pimg) && length($pimg) > 0);
	$pu = "anon" unless (defined($pu) && length($pu) > 0);
	$wpd = "Poemas" unless (defined($wpd) && length($wpd) > 0);

  	my $just_img = substr $pimg, 22;
	$in{"image_enc"} = $just_img;
  	$in{"image_dec"} = MIME::Base64::decode_base64($just_img);
	$in{"txt"} = $ptxt;
	$in{"pu"} = $pu;
	$in{"wpd"} = $wpd;

	return %in;
}

sub getpasswd {
	my $content;
    open(my $fh, '<', "wp-perl-password.txt") or die "cannot get password";
    {
        local $/;
        $content = <$fh>;
    }
    close($fh);
	return $content;
}

sub use_category {
	my ($cat, $pwd) = @_;
	my $wpdir;

	my $res = XMLRPC::Lite
	->proxy($server)
	->call('metaWeblog.getCategories', 1, 'perl', $pwd)
	->result;

	if (defined ($res)) {
		#my $call = $self->{ server }->call('metaWeblog.getCategories', 1, 'perl', $pwd);
		#$call->fault and croak 'get_categories: ', $call->faultstring;
		my @categories;
		push @categories, $_->{ categoryName } for @{$res};
		#print map { "$_\n" } @categories;
		$wpdir = $cat;
		$wpdir = "Poemas" unless (grep { $_ eq $cat} @categories);
	}
	else {
		$wpdir = 'Poemas';
	}

    return $wpdir;
}
