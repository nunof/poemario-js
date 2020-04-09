package WordPress;

use strict;
use warnings;

use Carp;
use XMLRPC::Lite;
use IO::Socket::SSL;
#use LWP::Simple;
#use LWP::UserAgent;


sub new {

    my ( $class, $proxy, $username, $password ) = @_;

	my $transporter=XMLRPC::Lite->new; 
	#$transporter->transport->ssl_opts(SSL_version => 'TLSv1.2');
	my $result=$transporter->proxy($proxy); 

    my $self = {
        server   => $result,
        username => $username,
        password => $password
    };
    bless $self, $class;
    return $self;
}


sub get_categories {

    my $self = shift;
    my $call = $self->{ server }->call(
        'metaWeblog.getCategories',
        1,                              # blogid, ignored
        $self->{ username },
        $self->{ password }
    );
    $call->fault and croak 'get_categories: ', $call->faultstring;

    my @categories;
    push @categories, $_->{ categoryName } for @{ $call->result };

    return \@categories;
}


sub post {

    my ( $self, $title, $description, $categories ) = @_;
    defined $categories or $categories = [];
    my $call = $self->{ server }->call(
        'metaWeblog.newPost',
        1,                              # blogid, ignored
        $self->{ username },
        $self->{ password }, {
            title       => $title,
            description => $description,
            categories  => $categories,
        },
        1                               # publish
    );
    $call->fault and croak 'get_categories: ', $call->faultstring;
}

1;
