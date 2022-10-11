package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Tuple;

use strict;
use warnings;
no indirect;

use Carp;
use parent qw(REFECO::Blockchain::SmartContracts::Solidity::ABI::Type);

sub configure {
    my $self = shift;

    my @splited_signatures = $self->split_tuple_signature()->@*;

    for (my $sig_index = 0; $sig_index < @splited_signatures; $sig_index++) {
        push $self->instances->@*,
            REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(
            signature => $splited_signatures[$sig_index],
            data      => $self->data->[$sig_index]);
    }
}

sub split_tuple_signature {
    my $self             = shift;
    my $tuple_signatures = substr($self->signature, 1, length($self->signature) - 2);
    $tuple_signatures =~ s/((\((?>[^)(]*(?2)?)*\))|[^,()]*)(*SKIP),/$1\n/g;
    my @types = split('\n', $tuple_signatures);
    return \@types;
}

sub encode {
    my $self = shift;
    return $self->encoded if $self->encoded;

    my $offset = $self->get_initial_offset;

    for my $instance ($self->instances->@*) {
        $instance->encode;
        if ($instance->is_dynamic) {
            $self->push_static($self->encode_offset($offset));
            $self->push_dynamic($instance->encoded);
            $offset += scalar $instance->encoded->@*;
            next;
        }

        $self->push_static($instance->encoded);
    }

    return $self->encoded;
}

1;

