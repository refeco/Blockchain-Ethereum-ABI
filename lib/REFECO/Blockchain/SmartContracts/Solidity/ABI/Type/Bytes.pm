package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Bytes;

use v5.26;
use strict;
use warnings;

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Bytes :does(Type) {

=head2 encode

Encodes an hexadecimal encoded byte array

=over 4

=back

Returns $self;

=cut

    method encode() {
        $self->value =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;
        my $hex              = $1;
        my $hex_padded_value = $hex . '0' x (64 - length($hex));
        my $hex_bytes_size   = $self->is_dynamic ? $self->encode_integer(length(pack("H*", $hex))) :'';

        $self->encoded_value($hex_bytes_size . $hex_padded_value);

        return $self;
    }

=head2 is_dynamic

Checks if the bytes type is static or not, it will be dynamic when there is no
size specified in the signature

=over 4

=back

Returns 1 or 0

=cut

    method is_dynamic() {
        return !$self->get_fixed_size_from_signature() ? 1 :0;
    }
}

1;

