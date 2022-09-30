package REFECO::Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::Ethereum::ABI::Type;

class ABI {
    use Digest::Keccak qw(keccak_256_hex);
    field @function_params;
    field $function_name;

    method append(%param) {
        for my $type_signature (keys %param) {
            if ($type_signature eq 'name') {
                $function_name = $param{$type_signature};
                next;
            }
            push(@function_params, Type->get_instance($type_signature, $param{$type_signature}));
        }

        return $self;
    }

    method generate_function_signature() {
        my $signature = $function_name . '(';
        $signature .= sprintf("%s,", $_->signature) for @function_params;
        chop $signature;
        return $signature . ')';
    }

    method encode_function_signature() {
        return sprintf("0x%.8s", keccak_256_hex($self->generate_function_signature));
    }

    method encode() {
        my (@static, @dynamic);
        push @static, $self->encode_function_signature() if $function_name;
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

