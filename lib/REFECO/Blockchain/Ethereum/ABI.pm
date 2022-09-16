package REFECO::Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

no indirect;

use Math::BigInt;
use Digest::Keccak qw(keccak_256_hex);

use REFECO::Blockchain::Ethereum::ABI::Type::Address;
use REFECO::Blockchain::Ethereum::ABI::Type::String;
use REFECO::Blockchain::Ethereum::ABI::Type::Bytes;
use REFECO::Blockchain::Ethereum::ABI::Type::Int;

use constant {
    OFFSET_BYTE_SIZE   => 32,
    OFFSET_STRING_SIZE => 64,
};

sub new {
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    return $self;
}

sub encode_function_signature {
    my ($self, %params) = @_;

    my $signature = $params{signature};
    return sprintf("0x%.8s", keccak_256_hex($signature));
}

sub encode_event_signature {
    my ($self, %params) = @_;

    my $signature = $params{signature};
    return sprintf("0x%s", keccak_256_hex($signature));
}

sub encode_parameter {
    my ($self, %params) = @_;

    my $signature = $params{type};
    my $value     = $params{value};

    # $self->get_type($signature)->encode($signature, $value);

    if ($signature =~ /^address$/) {
        return Address->new->encode($signature, $value);
    } elsif ($signature =~ /^(u)?(int|bool)(\d+)?$/) {
        return Int->new(signature => $signature)->encode($signature, $value);
    } elsif ($signature =~ /^(?:bytes)(\d+)?$/) {
        return Bytes->new->encode($signature, $value);
    } elsif ($signature =~ /^string$/) {
        return String->new->encode($signature, $value);
        # return $self->encode_string(value => $value);
    } elsif ($signature =~ /\[(\d+)?\]/gm) {
        return $self->encode_array(
            type  => $signature,
            value => $value
        );
    }
}

sub encode_parameters {
}

sub encode {
    my ($self, %params) = @_;

    my $signature = $params{signature};
    my $values    = $params{values};

    my @splited_signature = $self->split_function_signature(signature => $signature)->@*;
    my ($function_name, @function_params) = @splited_signature;

    my $encoded_signature = $self->encode_function_signature(signature => $signature);

    my @encoded;
    for (my $index = 0; $index < @function_params; $index++) {
        push @encoded,
            $self->encode_parameter(
            type  => $function_params[$index],
            value => $values->[$index]);
    }

    return @encoded;

}

sub decode_paramter {

}

sub decode_parameters {

}

sub decode_log {

}

sub encode_array {
    my ($self, %params) = @_;

    my $type  = $params{type};
    my $value = $params{value};

    $type =~ /(^[a-z]+(\d+)?)/;
    my $basic_type = $1;

    my @data;

    for my $item ($value->@*) {
        if (ref $item eq 'ARRAY') {
            push @data,
                $self->encode_array(
                type  => $type,
                value => $item
                );
        } else {
            push @data,
                $self->encode_parameter(
                type  => $basic_type,
                value => $item
                );
        }
    }

    return @data;
}

# sub get_function_offset_start {
#     my ($self, %params) = @_;
#     my $offset          = 0;
#     my @function_params = $params{function_params}->@*;
#     for my $param (@function_params) {
#         $param =~ /^([\w]+)([\d]+)?\[(\d+)?\]/;
#         my ($prefix_type, $size, $array_size) = ($1, $2, $3);
#         if ($size && $array_size || ($array_size && $prefix_type =~ /int|fixed/)) {
#             $offset += $array_size;
#             next;
#         }
#         $offset += 1;
#     }

#     return $offset;
# }

sub split_function_signature {
    my ($self, %params) = @_;

    my $signature = $params{signature};
    my @matches   = grep { $_ } $signature =~ /^(\w+)|([a-z0-9\[\]]+)[\s]+(?:\w+)/g;

    return \@matches;
}

1;

