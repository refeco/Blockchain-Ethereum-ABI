package REFECO::Blockchain::Ethereum::ABI::Type::Array;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Array :does(Type) {
    field @array_items;
    has $offset = 0;

    method encode() {
        my (@static, @dynamic);
        push @static, $self->encode_integer(scalar $self->value->@*) if $self->is_dynamic;
        $offset += scalar $self->value->@*;
        for my $item ($self->value->@*) {
            my $instance = Type->get_instance($self->remove_parent_array(), $item);
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

    method remove_parent_array() {
        my $new_signature = $self->get_base_signature;
        my @matches       = $self->signature =~ /\[(\d+)?\]/gm;
        shift @matches;

        $new_signature .= sprintf("[%s]", $_ // '') for @matches;

        return $new_signature;
    }

    method get_array_size_from_signature() {
        $self->signature =~ /\[(\d+)?\]/gm;
        return $1;
    }

    method decode() { }
    method is_dynamic {
        $self->signature =~ /(\d+)?\[(\d+)?\]/gm;
        return $1 && $2 ? 0 :1;
    }
}

1;
