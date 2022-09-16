package REFECO::Blockchain::Ethereum::ABI::Type::Int;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use Math::BigInt;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Int :does(Type) {
    method encode($signature, $value) {
        return sprintf("%064s", Math::BigInt->new($value)->to_hex);
    }

    method decode($signature, $value) { }
}

1;
