package REFECO::Blockchain::Ethereum::ABI::String;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class String :does(Type) {
    method encode($signature, $value) {
        my $hex              = unpack("H*", $value);
        my $hex_padded_value = $hex . '0' x (64 - length($hex));
        my $hex_string_size  = sprintf("%x", length($value));

        return sprintf("%064s%s", $hex_string_size, $hex_padded_value);
    }

    method decode($signature, $value) { }
}

1;
