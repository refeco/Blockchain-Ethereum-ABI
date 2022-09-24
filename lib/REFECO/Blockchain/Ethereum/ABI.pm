package REFECO::Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use Digest::Keccak qw(keccak_256_hex);

my $_package = __PACKAGE__;

class ABI {
    field @function_params;

    method append(%param) {
        for my $type_signature (keys %param) {
            push(@function_params, $self->get_type_instance($type_signature, $param{$type_signature}));
        }

        return $self;
    }

    method get_type_instance($type_signature, $value) {
        my $package;
        if ($type_signature =~ /^address$/) {
            $package = "Address";
        } elsif ($type_signature =~ /^(u)?(int|bool)(\d+)?$/) {
            $package = "Int";
        } elsif ($type_signature =~ /^(?:bytes)(\d+)?$/) {
            $package = "Bytes";
        } elsif ($type_signature =~ /^string$/) {
            $package = "String";
        } elsif ($type_signature =~ /\[(\d+)?\]/gm) {
        }

        (my $path = $_package) =~ s|::|/|g;
        my $package_file = sprintf("%s/Type/%s.pm", $path, $package);
        require $package_file;
        $package->import();
        return $package->new(
            signature => $type_signature,
            value     => $value,
        );
    }

    method encode() {
        my (@static, @dynamic);
        my $offset = $self->get_initial_position();
        for my $param (@function_params) {
            $param->encode();
            if ($param->is_dynamic) {
                push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
                push @dynamic, $param->encoded_size;
                push @dynamic, $param->encoded_value;
                $offset += 2;
            } else {
                push @static, $param->encoded_value;
            }
        }
        return join('', @static, @dynamic);
    }

    method get_initial_position() {
        my $offset = 0;
        for my $param (@function_params) {
            $param->signature =~ /^([\w]+)([\d]+)?\[(\d+)?\]/;
            my ($prefix_type, $size, $array_size) = ($1, $2, $3);
            if ($size && $array_size || ($array_size && $prefix_type =~ /int|fixed/)) {
                $offset += $array_size;
                next;
            }
            $offset += 1;
        }

        return $offset;
    }

}

1;

