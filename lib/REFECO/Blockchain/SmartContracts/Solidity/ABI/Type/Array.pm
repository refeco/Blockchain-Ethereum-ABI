package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Array;

use strict;
use warnings;
no indirect;

use Carp;
use parent qw(REFECO::Blockchain::SmartContracts::Solidity::ABI::Type);

sub configure {
    my $self = shift;
    for my $item ($self->data->@*) {
        push $self->instances->@*,
            REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(
            signature => $self->remove_parent(),
            data      => $item
            );
    }
}

sub encode {
    my $self = shift;
    return $self->encoded if $self->encoded;

    my $length = scalar $self->data->@*;
    # for dynamic length arrays the length must be included
    $self->push_static($self->encode_length($length))
        unless $self->fixed_length;

    croak "Invalid array size, signature @{[$self->fixed_length]}, data: $length"
        if $self->fixed_length && $length > $self->fixed_length;

    my $offset = $self->get_initial_offset();

    for my $instance ($self->instances->@*) {
        if ($instance->is_dynamic) {
            $self->push_static($self->encode_offset($offset));
        }

        $self->push_dynamic($instance->encode);
        $offset += scalar $instance->encode()->@*;
    }

    return $self->encoded;
}

sub remove_parent {
    my $self = shift;
    $self->signature =~ /(\[(\d+)?\]$)/;
    return substr $self->signature, 0, length($self->signature) - length($1 // '');
}

sub fixed_length {
    my $self = shift;
    if ($self->signature =~ /\[(\d+)?\]$/) {
        return $1;
    }
    return undef;
}

1;

