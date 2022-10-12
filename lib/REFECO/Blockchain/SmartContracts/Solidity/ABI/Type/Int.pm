package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Int;

use strict;
use warnings;
no indirect;

use Carp;
use Math::BigInt;
use parent qw(REFECO::Blockchain::SmartContracts::Solidity::ABI::Type);

sub encode {
    my $self = shift;
    return $self->encoded if $self->encoded;

    my $bdata = Math::BigInt->new($self->data);

    croak "Invalid numeric data @{[$self->data]}" if $bdata->is_nan;

    croak "Invalid data length, signature: @{[$self->fixed_length]}, data length: @{[$bdata->length]}"
        if $self->fixed_length && $bdata->length > $self->fixed_length;

    croak "Invalid negative numeric data @{[$self->data]}"
        if $bdata->is_neg && $self->signature =~ /^uint|bool/;

    croak "Invalid bool data it must be 1 or 0 but given @{[$self->data]}"
        if !$bdata->is_zero && !$bdata->is_one && $self->signature =~ /^bool/;

    $self->push_static($self->pad_left(Math::BigInt->new($self->data)->to_hex));

    return $self->encoded;
}

1;

