package REFECO::Blockchain::Ethereum::ABI::Type::Address;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class Address :does(Type) {
    method encode($signature, $value) {
        return sprintf("%064s", substr($value, 2));
    }

    method decode($signature, $value) { }
}

1;
