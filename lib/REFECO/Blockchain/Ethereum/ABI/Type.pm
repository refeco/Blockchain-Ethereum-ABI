package REFECO::Blockchain::Ethereum::ABI::Type;

use v5.26;
use strict;
use warnings;

use Object::Pad;

role Type {
    # package required parameters
    field $signature :param :accessor;
    field $value     :param :accessor;

    field $encoded_value :accessor;
    field $encoded_size  :accessor;

    method encode;
    method decode;
    method is_dynamic;
    method get_fixed_size_from_signature() {
        $self->signature =~ /^(?:[a-z]+)(\d+)?/;
        return $1;
    }
}

1;

