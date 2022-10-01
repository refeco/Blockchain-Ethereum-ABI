package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Address;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Address :does(Type) {
    method encode($value) {
        $self->encoded_value(sprintf("%064s", substr($value, 2)));
        return $self;
    }

    method decode($signature, $value) { }
    method is_dynamic() { }
}

1;
