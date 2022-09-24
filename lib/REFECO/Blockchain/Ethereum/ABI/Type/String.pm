package REFECO::Blockchain::Ethereum::ABI::Type::String;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class String :does(Type) {
    method encode() {
        my (@static, @dynamic);

        my $hex              = unpack("H*", $self->value);
        my $hex_padded_value = $hex . '0' x (64 - length($hex));
        my $hex_string_size  = sprintf("%x", length($self->value));

        $self->encoded_value($hex_padded_value);
        $self->encoded_size(sprintf("%064s", $hex_string_size));
        return $self;
    }

    method decode() { }
    method is_dynamic {
        return 1;
    }
}

1;
