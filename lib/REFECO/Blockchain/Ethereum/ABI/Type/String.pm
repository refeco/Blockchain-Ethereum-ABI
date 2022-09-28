package REFECO::Blockchain::Ethereum::ABI::Type::String;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class String :does(Type) {
    method encode() {
        my $hex              = unpack("H*", $self->value);
        my $hex_padded_value = $hex . '0' x (64 - length($hex));

        $self->encoded_value($self->encode_integer(length($self->value)) . $hex_padded_value);
        return $self;
    }

    method decode() { }
    method is_dynamic {
        return 1;
    }
}

1;
