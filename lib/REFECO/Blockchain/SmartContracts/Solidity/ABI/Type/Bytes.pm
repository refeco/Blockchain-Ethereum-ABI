package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Bytes;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Bytes :does(Type) {

    method encode() {
        $self->value =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;
        my $hex              = $1;
        my $hex_padded_value = $hex . '0' x (64 - length($hex));
        my $hex_bytes_size   = $self->is_dynamic ? $self->encode_integer(length(pack("H*", $hex))) :'';

        $self->encoded_value($hex_bytes_size . $hex_padded_value);

        return $self;
    }

    method decode() { }
    method is_dynamic() {
        return !$self->get_fixed_size_from_signature();
    }
}

1;

