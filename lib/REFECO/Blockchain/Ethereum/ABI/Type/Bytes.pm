package REFECO::Blockchain::Ethereum::ABI::Type::Bytes;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Bytes :does(Type) {

    method encode() {
        $self->value =~ /^(?:0x|0X)([a-fA-F0-9]+)$/;
        my $hex              = $1;
        my $hex_padded_value = $hex . '0' x (64 - length($hex));

        if ($self->is_dynamic()) {
            my $hex_bytes_size = length(pack("H*", $hex));
            $self->encoded_size(sprintf("%064s", $hex_bytes_size));
        }

        $self->encoded_value($hex_padded_value);

        return $self;
    }

    method decode() { }
    method is_dynamic() {
        return !$self->get_fixed_size_from_signature();
    }
}

1;

