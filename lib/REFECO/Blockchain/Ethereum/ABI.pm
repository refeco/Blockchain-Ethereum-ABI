package REFECO::Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use Digest::Keccak qw(keccak_256_hex);
use REFECO::Blockchain::Ethereum::ABI::Type;

class ABI {
    field @function_params;

    method append(%param) {
        for my $type_signature (keys %param) {
            push(@function_params, Type->get_instance($type_signature, $param{$type_signature}));
        }

        return $self;
    }

    method encode() {
        my (@static, @dynamic);
        my $offset = $self->get_initial_position();
        for my $param (@function_params) {
            $param->encode();
            if ($param->is_dynamic) {
                push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
                push @dynamic, $param->encoded_value;
                $offset += length($param->encoded_value) / 64;
            } else {
                push @static, $param->encoded_value;
            }
        }
        my @data = (@static, @dynamic);
        return join('', @data);
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

