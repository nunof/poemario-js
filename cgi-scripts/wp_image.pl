#!/usr/bin/perl

use strict;
use utf8;
use CGI qw(:standard);
use XMLRPC::Lite;
use IO::Socket::SSL;
use MIME::Base64 ();
use URI::Escape;

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

my $res = XMLRPC::Lite
->proxy($server)
->call('wp.uploadFile', 1, $username, $password,
{ name => "imagem_$publishdate.png", type => 'image/png', bits => $cgivars{'image_dec'}, overwrite => "true" } )
->result;

if (defined ($res)) {
	$pictureid = $res->{id};
	$pictureurl = $res->{url};
	print ". picture uploaded with id $pictureid\n";
} else {
        print " .. uploading picture failed: $!";
}

my $res = XMLRPC::Lite
->proxy($server)
->call('wp.newPost', 1, $username, $password,
{
		post_status  => "publish",
		post_content => "$cgivars{'txt'}\n\nfull image in $pictureurl",
    post_title => "poemario img $publishdate",
    #custom_fields => [
		#	{ "key" => "_thumbnail_id", "value" => $pictureid },
		#	{ "key" => "_thumbnail_url", "value" => $pictureurl }
		#]
		post_thumbnail => $pictureid
  }, 1)->result;

if (defined ($res)) {
		#my $res2 = XMLRPC::Lite
		#->proxy($server)
		#->call('metaWeblog.editPost', $res, $username, $password,
		#{
	  #       post_status  => "publish",
    #       mt_keywords => "poemario",
						#custom_fields => [ { "key" => "_thumbnail_id", "value" => $pictureid } ]
		#				wp_post_thumbnail => $pictureid
		#}, 1)->result;

		#if (defined ($res2)) {
    #	print ". posted id $res and edited article id $res2 to picture id $pictureid\n";
		#}
		#else { ". posted id $res but failed to edit article id $res2 to picture id $pictureid\n"; }
		print ". posted id $res to picture id $pictureid\n";
} else {
        print ".. posting article with id $res failed: $!";
}

sub getcgivars {

	my %in = ();
	my $req_method = $ENV{'REQUEST_METHOD'};
	return %in unless($req_method eq 'POST');
  my @params = param();
  my $pn = "";
  foreach $pn ( @params ) { print "$pn \n"; }

	my $pimg = uri_unescape(param("img"));
	my $ptxt = uri_unescape(param("txt"));

	return () unless (defined($ptxt) && length($ptxt) > 0);
	return () unless (defined($pimg) && length($pimg) > 0);

  my $just_img = substr $pimg, 22;
	$in{"image_enc"} = $just_img;
  $in{"image_dec"} = MIME::Base64::decode_base64($just_img);
	$in{"txt"} = $ptxt;

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