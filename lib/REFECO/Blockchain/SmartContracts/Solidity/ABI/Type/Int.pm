package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Int;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use Math::BigInt;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Int :does(Type) {

=head2 encode

Encodes integer

=over 4

=back

Returns $self;

=cut

    method encode() {
        $self->encoded_value(sprintf("%064s", Math::BigInt->new($self->value)->to_hex));
        return $self;
    }

=head2 is_dynamic

Integer based types are always static since it will be handled as 256 if no fixed
size is given

=over 4

=back

Returns 0;

=cut

    method is_dynamic() {
        return 0;
    }
}

1;
