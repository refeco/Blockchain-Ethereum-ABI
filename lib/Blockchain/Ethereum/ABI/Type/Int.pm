use v5.26;
use Object::Pad;

package Blockchain::Ethereum::ABI::Type::Int 0.012;
class Blockchain::Ethereum::ABI::Type::Int
    :isa(Blockchain::Ethereum::ABI::Type)
    :does(Blockchain::Ethereum::ABI::TypeRole);

=encoding utf8

=head1 NAME

Blockchain::Ethereum::ABI::Int - Interface for solidity uint/int/bool type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity address type:

    my $type = Blockchain::Ethereum::ABI::Int->new(
        signature => $signature,
        data      => $value
    );

    $type->encode();

In most cases you don't want to use this directly, use instead:

=over 4

=item * B<Encoder>: L<Blockchain::Ethereum::ABI::Encoder>

=item * B<Decoder>: L<Blockchain::Ethereum::ABI::Decoder>

=back

=cut

use Carp;
use Math::BigInt try => 'GMP';
use Scalar::Util qw(looks_like_number);

use constant DEFAULT_INT_SIZE => 256;

method _configure { return }

=head2 encode

Encodes the given data to the type of the signature

Usage:

    encode() -> encoded string

=over 4

=back

ABI encoded hex string

=cut

method encode {

    return $self->_encoded if $self->_encoded;

    croak "Invalid numeric data @{[$self->data]}" unless looks_like_number($self->data);

    my $bdata = Math::BigInt->new($self->data);

    croak "Invalid numeric data @{[$self->data]}" if $bdata->is_nan;

    croak "Invalid data length, signature: @{[$self->fixed_length]}, data length: @{[$bdata->length]}"
        if $self->fixed_length && $bdata->length > $self->fixed_length;

    croak "Invalid negative numeric data @{[$self->data]}"
        if $bdata->is_neg && $self->signature =~ /^uint|bool/;

    croak "Invalid bool data it must be 1 or 0 but given @{[$self->data]}"
        if !$bdata->is_zero && !$bdata->is_one && $self->signature =~ /^bool/;

    $self->_push_static($self->pad_left($bdata->to_hex));

    return $self->_encoded;
}

=head2 decode

Decodes the given data to the type of the signature

Usage:

    decoded() -> L<Math::BigInt>

=over 4

=back

L<Math::BigInt>

=cut

method decode {

    return Math::BigInt->from_hex($self->data->[0]);
}

method fixed_length :override {

    if ($self->signature =~ /[a-z](\d+)/) {
        return $1;
    }
    return DEFAULT_INT_SIZE;
}

1;

__END__

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
