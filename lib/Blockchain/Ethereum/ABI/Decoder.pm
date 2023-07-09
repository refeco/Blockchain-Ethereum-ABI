package Blockchain::Ethereum::ABI::Decoder;

use v5.26;
use strict;
use warnings;
use feature 'signatures';
no indirect ':fatal';

use Carp;

use Blockchain::Ethereum::ABI::Type;
use Blockchain::Ethereum::ABI::Type::Tuple;

sub new ($class) {

    return bless {}, $class;
}

sub _instances ($self) {

    return $self->{instances} //= [];
}

sub append ($self, $param) {

    state $type = Blockchain::Ethereum::ABI::Type->new;

    push $self->_instances->@*, $type->new_type(signature => $param);
    return $self;
}

sub decode ($self, $hex_data) {

    croak 'Invalid hexadecimal value ' . $hex_data // 'undef'
        unless $hex_data =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;

    my $hex  = $1;
    my @data = unpack("(A64)*", $hex);

    my $tuple = Blockchain::Ethereum::ABI::Type::Tuple->new;
    $tuple->{instances} = $self->_instances;
    $tuple->{data}      = \@data;
    my $data = $tuple->decode;

    $self->_clean;
    return $data;
}

sub _clean ($self) {

    delete $self->{instances};
}

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Decoder - Contract ABI response decoder

=head1 SYNOPSIS

Allows you to decode contract ABI response

    my $decoder = Blockchain::Ethereum::ABI::Decoder->new();
    $decoder
        ->append('uint256')
        ->append('bytes[]')
        ->decode('0x...');
    ...

=head1 METHODS

=head2 append

Appends type signature to the decoder.

Usage:

    append(signature) -> L<Blockchain::Ethereum::ABI::Encoder>

=over 4

=item * C<$param> type signature e.g. uint256

=back

Returns C<$self>

=head2 decode

Decodes appended signatures

Usage:

    decode() -> []

=over 4

=back

Returns an array reference containing all decoded values

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Encoder

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
