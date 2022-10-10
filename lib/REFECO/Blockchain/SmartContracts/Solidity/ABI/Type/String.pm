package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::String;

use strict;
use warnings;
no indirect;

use Carp;
use parent qw(REFECO::Blockchain::SmartContracts::Solidity::ABI::Type);

sub encode {
    my $self = shift;
    return $self->encoded if $self->encoded;

    my $hex = unpack("H*", $self->data);

    unless ($self->fixed_length) {
        # for dynamic length basic types the length must be included
        $self->push_dynamic($self->encode_length(length(pack("H*", $hex))));
        $self->push_dynamic($self->pad_right($hex));
    } else {
        $self->push_static($self->pad_right($hex));
    }

    return $self->encoded;
}

1;

