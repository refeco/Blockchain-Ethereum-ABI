package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Address;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Address :does(Type) {

=head2 encode

Encodes address

=over 4

=back

Returns $self;

=cut

    method encode($value) {
        $self->encoded_value(sprintf("%064s", substr($value, 2)));
        return $self;
    }

=head2 is_dynamic

Addresses will always be static

=over 4

=back

Returns 0;

=cut

    method is_dynamic() {
        return 0;
    }
}

1;
