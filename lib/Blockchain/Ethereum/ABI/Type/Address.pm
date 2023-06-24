package Blockchain::Ethereum::ABI::Type::Address;

use v5.26;
use strict;
use warnings;

use Carp;
use parent qw(Blockchain::Ethereum::ABI::Type);

sub encode {
    my $self = shift;
    return $self->_encoded if $self->_encoded;
    $self->_push_static($self->pad_left(substr($self->_data, 2)));

    return $self->_encoded;
}

sub decode {
    my $self = shift;
    return '0x' . substr $self->_data->[0], -40;
}

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Address - Interface for solidity address type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity address type:

    my $type = Blockchain::Ethereum::ABI::Address->new(
        signature => $signature,
        data      => $value
    );

    $type->encode();
    ...

In most cases you don't want to use this directly, use instead:

=over 4

=item * B<Encoder>: L<Blockchain::Ethereum::ABI::Encoder>

=item * B<Decoder>: L<Blockchain::Ethereum::ABI::Decoder>

=back

=head1 METHODS

=head2 encode

Encodes the given data to the type of the signature

Usage:

    encode() -> encoded string

=over 4

=back

=head2 decode

Decodes the given data to the type of the signature

Usage:

    decoded() -> address

=over 4

=back

String 0x prefixed address

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Address

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
