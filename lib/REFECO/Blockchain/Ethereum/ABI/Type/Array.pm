package REFECO::Blockchain::Ethereum::ABI::Type::Array;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

# [[1, 2], [3]]

class Array :does(Type) {
    use Scalar::Util qw(reftype);
    field @array_items;
    has $offset = 0;

    method encode() {
        my (@static, @dynamic);
        push @static, $self->encode_integer(scalar $self->value->@*);
        $offset += scalar $self->value->@*;
        for my $item ($self->value->@*) {
            my $item_reference = reftype($item);
            my $base_signature = $item_reference && $item_reference eq 'ARRAY' ? $self->signature :$self->get_base_signature;

            my $instance = Type->get_instance($base_signature, $item);
            if ($instance->is_dynamic) {
                push @static, $self->encode_offset($offset);
            }

            my $child_encoded_value = $instance->encode()->encoded_value();

            push @dynamic, $child_encoded_value;
            $offset += length($child_encoded_value) / 64;
        }

        $self->encoded_value(join('', @static, @dynamic));
        return $self;
    }

    method decode() { }
    method is_dynamic {
        return 1;
    }
}

1;
