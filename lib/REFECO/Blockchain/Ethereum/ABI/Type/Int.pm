package REFECO::Blockchain::Ethereum::ABI::Type::Int;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use Math::BigInt;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Int :does(Type) {
    method encode() {
        $self->encoded_value(sprintf("%064s", Math::BigInt->new($self->value)->to_hex));
        return $self;
    }

    method decode() { }
    method is_dynamic() {
        return 0;
    }
}

1;
