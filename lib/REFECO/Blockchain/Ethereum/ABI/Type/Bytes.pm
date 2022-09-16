package REFECO::Blockchain::Ethereum::ABI::Type::Bytes;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Bytes :does(Type) {

    method encode($signature, $value) {
        $value =~ /^(?:0x|0X)([a-fA-F0-9]+)$/;
        my $hex              = $1;
        my $hex_padded_value = $hex . '0' x (64 - length($hex));

        if ($self->size($signature)) {
            return $hex_padded_value;
        }

        my $hex_bytes_size = length(pack("H*", $hex));

        return sprintf("%064s%s", $hex_bytes_size, $hex_padded_value);
    }

    method decode() { }
}

1;

