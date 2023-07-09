package Blockchain::Ethereum::ABI::Type::String;

use v5.26;
use strict;
use warnings;
use feature 'signatures';
no indirect ':fatal';

use parent qw(Blockchain::Ethereum::ABI::Type);

sub encode ($self) {

    return $self->_encoded if $self->_encoded;

    my $hex = unpack("H*", $self->_data);

    # for dynamic length basic types the length must be included
    $self->_push_dynamic($self->_encode_length(length(pack("H*", $hex))));
    $self->_push_dynamic($self->pad_right($hex));

    return $self->_encoded;
}

sub decode ($self) {

    my @data = $self->_data->@*;

    my $size          = hex shift @data;
    my $string_data   = join('', @data);
    my $packed_string = pack("H*", $string_data);
    return substr($packed_string, 0, $size);
}

1;

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::String - Interface for solidity string type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity string type:

    my $type = Blockchain::Ethereum::ABI::String->new(
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

    decoded() -> string

=over 4

=back

String

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::String

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
