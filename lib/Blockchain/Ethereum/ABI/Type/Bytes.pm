package Blockchain::Ethereum::ABI::Type::Bytes;

use v5.26;
use strict;
use warnings;
use feature 'signatures';
no indirect ':fatal';

use Carp;
use parent qw(Blockchain::Ethereum::ABI::Type);

sub encode ($self) {

    return $self->_encoded if $self->_encoded;
    # remove 0x and validates the hexadecimal value
    croak 'Invalid hexadecimal value ' . $self->_data // 'undef'
        unless $self->_data =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;
    my $hex = $1;

    my $data_length = length(pack("H*", $hex));
    unless ($self->fixed_length) {
        # for dynamic length basic types the length must be included
        $self->_push_dynamic($self->_encode_length($data_length));
        $self->_push_dynamic($self->pad_right($hex));
    } else {
        croak "Invalid data length, signature: @{[$self->fixed_length]}, data length: $data_length"
            if $self->fixed_length && $data_length != $self->fixed_length;
        $self->_push_static($self->pad_right($hex));
    }

    return $self->_encoded;
}

sub decode ($self) {

    my @data = $self->_data->@*;

    my $hex_data;
    my $size = $self->fixed_length;
    unless ($self->fixed_length) {
        $size = hex shift @data;

        $hex_data = join('', @data);
    } else {
        $hex_data = $data[0];
    }

    my $bytes = substr(pack("H*", $hex_data), 0, $size);
    return sprintf "0x%s", unpack("H*", $bytes);
}

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Bytes - Interface for solidity bytes type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity bytes type:

    my $type = Blockchain::Ethereum::ABI::Bytes->new(
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

    decoded() -> hexadecimal encoded bytes

=over 4

=back

hexadecimal encoded bytes string

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Bytes

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
