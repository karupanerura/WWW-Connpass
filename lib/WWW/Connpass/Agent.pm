package WWW::Connpass::Agent;
use strict;
use warnings;

use parent qw/WWW::Mechanize/;

use Time::HiRes qw/gettimeofday tv_interval/;

sub new {
    my ($class, %args) = @_;
    my $interval = delete $args{interval} || 1.0;
    my $self = $class->SUPER::new(%args);
    $self->{_interval}    = $interval;
    $self->{_last_req_at} = undef;
    return $self;
}

sub request {
    my $self = shift;
    if (my $last_req_at = $self->{_last_req_at}) {
        my $sec = tv_interval($last_req_at);
        Time::HiRes::sleep $self->{_interval} - $sec if $sec < $self->{_interval};
    }
    my $res = $self->SUPER::request(@_);
    $self->{_last_req_at} = [gettimeofday];
    return $res;
}

sub extract_cookie {
    my ($self, $expected_key) = @_;

    my $result;
    $self->cookie_jar->scan(sub {
        my ($key, $val) = @_[1..2];
        return if defined $result;
        return if $key ne $expected_key;
        $result = $val;
    });

    return $result;
}

1;
__END__
