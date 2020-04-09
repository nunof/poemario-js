#! /usr/bin/perl 
use CGI qw(:standard);
use WordPress;
use URI::Escape;
#use Data::Dumper;

my $poem_user = "Anonimo";
my $wp_user = "perl";
my $wp_pass = &getpasswd;
my $wp_server = "http://telepoesis.net/poemario/xmlrpc.php";
my $poem = "teste";
my $wpdir = "Poemas";
my $is_ok = &getcgivars();

#&log_request($poema, $wpdir, $username);

print "Content-type: text/plain\n\n";
if ($is_ok) {
	print "HTTP 200\n";
}
else {
	print "HTTP 400\n";
	exit 0;
}

if (defined($poem) && length($poem) > 0) {

	$wpdir = "Poemas" if (!defined($wpdir) || $wpdir eq "");
	my $wp_obj = WordPress->new($wp_server, $wp_user, $wp_pass);
	my @categories = @{ $wp_obj->get_categories };
	#print map { "$_\n" } @categories;
	my $w = $wpdir;
	$wpdir = "Poemas" unless (grep { $_ eq $w} @categories);
	my $rand_title = &get_rand_title($poem);
	$wp_obj->post("$rand_title, por $poem_user", $poem, [$wpdir]);
}

sub log_request() {
	
	my ($a, $b, $c) = @_;
	my $date_time = localtime();
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	$year += 1900;
	$mon++;
	my $date_time = "$year$mon$mday$hour$min";
	#my $date_time = time();
	my $cli_ip = $ENV{'REMOTE_ADDR'}; 
	my $cli_ua = $ENV{'HTTP_USER_AGENT'}; 
	my $cli_rf = $ENV{'HTTP_REFERER'}; 

	open(DATLOG,">>/home/telepoes/public_html/nunof/wordpress.log") || die("silent death"); 
	print DATLOG "$date_time>>>$cli_ip>>>$cli_ua>>>$cli_rf>>>$a>>>$b>>>$c\n";
	close(DATLOG);
}

sub get_rand_title() {

	my $p = shift;
	my @ptmp = split(/ /, $p);
	return $p unless(scalar(@ptmp) > 2);
	my $stmp = "";
	my $count = 0;
	my $title = "";
	while (1) {
		$stmp = $ptmp[int(rand(scalar(@ptmp)))];
		$stmp =~ s/,//;
		$stmp =~ s/ *$//;
		if (length($stmp) > 2) {
			$title .= " $stmp";
			$count++;
		}
		last if ($count == 2 || $count > 4);
	}
	$title =~ s/^ //;
	$title =~ s/ *$//;
	return $title;
}

sub getcgivars {

	my $req_method = $ENV{'REQUEST_METHOD'};
	return 0 unless($req_method eq 'POST');

	my $main_param = uri_unescape(param("poem"));
	return 0 unless (defined($main_param) && length($main_param) > 0);

    $poem = $main_param;
    $poem_user = uri_unescape(param("poem_user"));
    $wpdir = uri_unescape(param("wp_dir"));
	return 1;
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