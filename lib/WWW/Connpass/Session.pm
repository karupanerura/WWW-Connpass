package WWW::Connpass::Session;
use strict;
use warnings;

use Carp qw/croak/;
use HTTP::Request::Common;
use Web::Query qw/wq/;
use JSON 2;

use WWW::Connpass::Agent;
use WWW::Connpass::Event;
use WWW::Connpass::Group;

my $_JSON = JSON->new->utf8;

sub new {
    my ($class, $user, $pass, $opt) = @_;

    my $mech = WWW::Connpass::Agent->new(%$opt, cookie_jar => {});
    $mech->get('https://connpass.com/login/');
    $mech->form_id('login_form');
    $mech->set_fields(username => $user, password => $pass);
    my $res = $mech->submit();
    unless ($res->is_success) {
        my $message = sprintf '[ERROR] %d %s: %s', $res->status, $res->message, $res->body;
        croak $message;
    }

    my $error = wq($res->decoded_content)->find('.errorlist > li')->map(sub { $_->text });
    if (@$error) {
        my $message = join "\n", @$error;
        croak "Failed to login by user: $user. error: $message";
    }

    return bless {
        mech => $mech,
        user => $user,
    } => $class;
}

sub user { shift->{user} }

sub _csrf_token {
    my $self = shift;
    $self->{_csrf_token} ||= $self->{mech}->extract_cookie('connpass-csrftoken');
}

sub new_event {
    my ($self, $title) = @_;

    my $content = $_JSON->encode({ title => $title, place => undef });
    my $req = POST 'http://connpass.com/api/event/',
        'Content-Type'     => 'application/json',
        'Content-Length'   => length $content,
        'X-CSRFToken'      => $self->_csrf_token(),
        'X-Requested-With' => 'XMLHttpRequest',
        Content => $content;

    my $res = $self->{mech}->request($req);
    unless ($res->is_success) {
        my $message = sprintf '[ERROR] %d %s: %s', $res->status, $res->message, $res->body;
        croak $message;
    }

    my $data = $_JSON->decode($res->decoded_content);
    return WWW::Connpass::Event->new(session => $self, event => $data);
}

sub update_event {
    my ($self, $event, $diff) = @_;
    my $uri = sprintf 'http://connpass.com/api/event/%d', $event->id;
    my $content = $_JSON->encode({
        %{ $event->raw_data },
        %$diff,
    });

    my $req = PUT $uri,
        'Content-Type'     => 'application/json',
        'Content-Length'   => length $content,
        'X-CSRFToken'      => $self->_csrf_token(),
        'X-Requested-With' => 'XMLHttpRequest',
        Content => $content;

    my $res = $self->{mech}->request($req);
    unless ($res->is_success) {
        my $message = sprintf '[ERROR] %d %s: %s', $res->status, $res->message, $res->body;
        croak $message;
    }

    $event = $_JSON->decode($res->decoded_content);
    return WWW::Connpass::Event->new(session => $self, event => $event);
}

sub fetch_managed_events {
    my $self = shift;
    my $res = $self->{mech}->get('http://connpass.com/editmanage/');
    return map { WWW::Connpass::Event->new(session => $self, event => $_) }
        map { $_JSON->decode($_) } @{
            wq($res->decoded_content)->find('#EventManageTable .event_list > table')->map(sub { $_->data('obj') })
        };
}

sub fetch_organized_groups {
    my $self = shift;
    my $res = $self->{mech}->get('http://connpass.com/group/');

    my $groups = wq($res->decoded_content)->find('.series_lists_area .series_list .title a')->map(sub {
        my $title  = $_->text;
        my $url    = $_->attr('href');
        my ($id)   = wq($self->{mech}->get($url)->decoded_content)->find('.icon_gray_edit')->parent()->attr('href') =~ m{/series/([^/]+)/edit/$};
        my ($name) = $url =~ m{^https?://([^.]+)\.connpass\.com/};
        return unless $id;
        return {
            id    => $id,
            name  => $name,
            title => $title,
            url   => $url,
        };
    });

    return map { WWW::Connpass::Group->new(session => $self, group => $_) } @$groups;
}

1;
__END__

=pod

=encoding utf-8

=head1 NAME

WWW::Connpass::Session - TODO

=head1 SYNOPSIS

    use WWW::Connpass::Session;

=head1 DESCRIPTION

TODO

=head1 SEE ALSO

L<perl>

=head1 LICENSE

Copyright (C) karupanerura.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

karupanerura E<lt>karupa@cpan.orgE<gt>

=cut
