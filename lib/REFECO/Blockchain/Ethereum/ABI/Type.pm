package REFECO::Blockchain::Ethereum::ABI::Type;

use v5.26;
use strict;
use warnings;

use Object::Pad;

role Type {
    method encode;
    method decode;

    method size($signature) {
        $signature =~ /^(?:[a-z]+)(\d+)?/;
        return $1;
    }
}

1;

