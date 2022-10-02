package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::String;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class String :does(Type) {

=head2 encode

Encodes string

=over 4

=back

Returns $self;

=cut

    method encode() {
        my $hex              = unpack("H*", $self->value);
        my $hex_padded_value = $hex . '0' x (64 - length($hex));

        # add the string size and the string encoded
        $self->encoded_value($self->encode_integer(length($self->value)) . $hex_padded_value);
        return $self;
    }

=head2 is_dynamic

Strings are always dynamic

=over 4

=back

Returns 1;

=cut

    method is_dynamic() {
        return 1;
    }
}

1;
