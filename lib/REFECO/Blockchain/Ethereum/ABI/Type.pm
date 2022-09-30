package REFECO::Blockchain::Ethereum::ABI::Type;

use v5.26;
use strict;
use warnings;

use Object::Pad;

my $_package = __PACKAGE__;

role Type {
    # package required parameters
    field $signature :param :accessor;
    field $value     :param :accessor;

    field $encoded_value :accessor;

    method encode;
    method decode;
    method is_dynamic;

    method get_fixed_size_from_signature() {
        $self->signature =~ /^(?:[a-z]+)(\d+)?/;
        return $1;
    }

    method get_base_signature() {
        $self->signature =~ /^([a-z]+(\d+)?)/;
        return $1;
    }

    method encode_integer($value) {
        return sprintf("%064s", sprintf("%x", $value));
    }

    method encode_offset($value) {
        return $self->encode_integer($value * 32);
    }

    method get_instance :common :($signature, $value) {
        $DB::single = 1;
        my $package;
        if ($signature =~ /\[(\d+)?\]/gm) {
            $package = "Array";
        } elsif ($signature =~ /^address$/) {
            $package = "Address";
        } elsif ($signature =~ /^(u)?(int|bool)(\d+)?$/) {
            $package = "Int";
        } elsif ($signature =~ /^(?:bytes)(\d+)?$/) {
            $package = "Bytes";
        } elsif ($signature =~ /^string$/) {
            $package = "String";
        } else {
            die "Module not found for the given parameter signature";
        }

        (my $path = $_package) =~ s|::|/|g;
        my $package_file = sprintf("%s/%s.pm", $path, $package);
        require $package_file;
        $package->import();
        return $package->new(
            signature => $signature,
            value     => $value,
        );
    }

}

1;

