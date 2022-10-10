package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Int;

use strict;
use warnings;
no indirect;

use Carp;
use Math::BigInt;
use parent qw(REFECO::Blockchain::SmartContracts::Solidity::ABI::Type);

sub encode {
    my $self = shift;
    return $self->encoded if $self->encoded;
    $self->push_static($self->pad_left(Math::BigInt->new($self->data)->to_hex));

    return $self->encoded;
}

1;

