package WWW::Connpass::Event::Waitlist;
use strict;
use warnings;

sub new {
    my $class = shift;
    bless {@_} => $class;
}

sub cancelled_count          { shift->{cancelled_count}           }
sub id                       { shift->{id}                        }
sub join_fee                 { shift->{join_fee}                  }
sub lottery_count            { shift->{lottery_count}             }
sub max_participants         { shift->{max_participants}          }
sub method                   { shift->{method}                    }
sub name                     { shift->{name}                      }
sub participants_count       { shift->{participants_count}        }
sub place_fee                { shift->{place_fee}                 }
sub total_participants_count { shift->{total_participants_count}  }
sub waitlist_count           { shift->{waitlist_count}            }

1;
__END__

=pod

=encoding utf-8

=head1 NAME

WWW::Connpass::Event::Waitlist - TODO

=head1 SYNOPSIS

    use WWW::Connpass::Event::Waitlist;

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
