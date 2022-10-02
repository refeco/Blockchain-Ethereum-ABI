package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Array;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Array :does(Type) {
    field @array_items;
    has $offset = 0;

=head2 encode

Encode array and multidimensional arrays

=over 4

=back

Returns $self;

=cut

    method encode() {
        my (@static, @dynamic);
        push @static, $self->encode_integer(scalar $self->value->@*) if $self->is_dynamic;
        # the array class must control the internal offset since the multidimensional
        # arrays will have their own internal offset as well
        $offset += scalar $self->value->@*;
        for my $item ($self->value->@*) {
            # recursive calling the instance to handle whatever value is given
            # the remove parent array will return the base type signature if no
            # following array is found
            my $instance = Type->get_instance($self->remove_parent_array(), $item);
            # this is basically the same done by the encoded, but since it is an
            # internal offset it needs to be done here again
            if ($instance->is_dynamic) {
                push @static, $self->encode_offset($offset);
            }

            my $child_encoded_value = $instance->encode()->encoded_value();

            push @dynamic, $child_encoded_value;
            # 64 characters = 32 bytes
            $offset += length($child_encoded_value) / 64;
        }

        $self->encoded_value(join('', @static, @dynamic));
        return $self;
    }

=head2 remove_parent_array

Remove the current array from the array signature, eg. uint[2][] will be uint[]
after this method call

=over 4

=back

Returns the new signature without the parent array

=cut

    method remove_parent_array() {
        my $new_signature = $self->get_base_signature;
        my @matches       = $self->signature =~ /\[(\d+)?\]/gm;
        shift @matches;

        $new_signature .= sprintf("[%s]", $_ // '') for @matches;

        return $new_signature;
    }

=head2 get_array_size_from_signature

Filter out the array size from the type signature

=over 4

=back

Returns an unsigned integer or undef

=cut

    method get_array_size_from_signature() {
        $self->signature =~ /\[(\d+)?\]/gm;
        return $1;
    }

=head2 is_dynamic

Checks is the array is dynamic or static, it will be always static unless the
base parameter is fixed and the array size is defined

=over 4

=back

Returns 1 or 0

=cut

    method is_dynamic {
        $self->signature =~ /(\d+)?\[(\d+)?\]/gm;
        return $1 && $2 ? 0 :1;
    }
}

1;
