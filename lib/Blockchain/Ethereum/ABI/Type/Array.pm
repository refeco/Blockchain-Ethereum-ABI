use v5.26;
use Object::Pad;
# ABSTRACT: Solidity array type interface

package Blockchain::Ethereum::ABI::Type::Array;
class Blockchain::Ethereum::ABI::Type::Array
    :isa(Blockchain::Ethereum::ABI::Type)
    :does(Blockchain::Ethereum::ABI::TypeRole);

# AUTHORITY
# VERSION

=head1 SYNOPSIS

Allows you to define and instantiate a solidity tuple type:

    my $type = Blockchain::Ethereum::ABI::Array->new(
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

method _configure {

    return unless $self->data;

    for my $item ($self->data->@*) {
        push $self->_instances->@*,
            Blockchain::Ethereum::ABI::Type->new(
            signature => $self->_remove_parent,
            data      => $item
            );
    }
}

=method encode

Encodes the given data to the type of the signature

=over 4

=back

ABI encoded hex string

=cut

method encode {

    return $self->_encoded if $self->_encoded;

    my $length = scalar $self->data->@*;
    # for dynamic length arrays the length must be included
    $self->_push_static($self->_encode_length($length))
        unless $self->fixed_length;

    croak "Invalid array size, signature @{[$self->fixed_length]}, data: $length"
        if $self->fixed_length && $length > $self->fixed_length;

    my $offset = $self->_get_initial_offset;

    for my $instance ($self->_instances->@*) {
        $self->_push_static($self->_encode_offset($offset))
            if $instance->is_dynamic;

        $self->_push_dynamic($instance->encode);
        $offset += scalar $instance->encode()->@*;
    }

    return $self->_encoded;
}

=method decode

Decodes the given data to the type of the signature

=over 4

=back

Array reference

=cut

method decode {

    my @data = $self->data->@*;

    my $size = $self->fixed_length // shift $self->data->@*;
    push $self->_instances->@*, Blockchain::Ethereum::ABI::Type->new(signature => $self->_remove_parent) for 0 .. $size - 1;

    return $self->_read_stack_set_data;
}

method _remove_parent {

    $self->signature =~ /(\[(\d+)?\]$)/;
    return substr $self->signature, 0, length($self->signature) - length($1 // '');
}

method fixed_length :override {

    if ($self->signature =~ /\[(\d+)?\]$/) {
        return $1;
    }
    return undef;
}

method _static_size :override {

    return 1 if $self->is_dynamic;

    my $size = $self->fixed_length;

    my $instance_size = 1;
    for my $instance ($self->_instances->@*) {
        $instance_size += $instance->_static_size;
    }

    return $size * $instance_size;
}

1;
