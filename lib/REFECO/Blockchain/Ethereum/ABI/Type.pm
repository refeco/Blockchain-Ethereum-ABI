package REFECO::Blockchain::Ethereum::ABI::Type;

use v5.26;
use strict;
use warnings;

use Object::Pad;

role Type {
    has $value_type :param;
    has $type_class;

    BUILD() {
        $value_type =~ /^([a-z]+)(?:\d+)?/;
        my $package = sprintf("%s::%s", __PACKAGE__, ucfirst $1);
    }

    method encode;
    method decode;

    method size($signature) {
        $signature =~ /^(?:[a-z]+)(\d+)?/;
        return $1;
    }
}

1;

