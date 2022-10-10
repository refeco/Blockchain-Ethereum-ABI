package REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

use strict;
use warnings;
no indirect;

our $VERSION = '0.001';

use Carp;
use Digest::Keccak qw(keccak_256_hex);
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub instances {
    my $self = shift;
    return $self->{instances} //= [];
}

sub function_name {
    my $self = shift;
    return $self->{function_name};
}

sub append {
    my ($self, %param) = @_;

    for my $type_signature (keys %param) {
        push(
            $self->instances->@*,
            REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(
                signature => $type_signature,
                data      => $param{$type_signature}));
    }

    return $self;
}

sub function {
    my ($self, $function_name) = @_;
    $self->{function_name} = $function_name;
    return $self;
}

sub generate_function_signature {
    my $self = shift;
    croak "Missing function name eg. ->function('name')" unless $self->function_name;
    my $signature = $self->function_name . '(';
    $signature .= sprintf("%s,", $_->signature) for $self->instances->@*;
    chop $signature;
    return $signature . ')';
}

sub encode_function_signature {
    my ($self, $signature) = @_;
    return sprintf("0x%.8s", keccak_256_hex($signature // $self->generate_function_signature));
}

sub encode {
    my $self = shift;
    my (@static, @dynamic);

    push @static, $self->encode_function_signature()
        if $self->function_name;

    my $offset = $self->get_initial_offset();

    for my $param ($self->instances->@*) {
        my $encoded = join('', $param->encode->@*);
        # for dynamic items the offset must be included
        if ($param->is_dynamic) {
            push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
            push @dynamic, $encoded;
            $offset += scalar $param->encode->@*;
        } else {
            # static items require only the encoded value
            push @static, $encoded;
        }
    }

    my @data = (@static, @dynamic);
    return join('', @data);
}

sub get_initial_offset {
    my $self   = shift;
    my $offset = 0;
    for my $param ($self->instances->@*) {
        my $encoded = $param->encode();
        if ($param->is_dynamic) {
            $offset += 1;
        } else {
            $offset += scalar $param->encoded->@*;
        }
    }

    return $offset;
}

sub clear {
    my $self = shift;
    delete $self->{instances};
    undef $self->{function_name};
}

1;

