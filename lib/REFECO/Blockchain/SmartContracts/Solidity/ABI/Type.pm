package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

use v5.26;
use strict;
use warnings;

use Object::Pad;

my $_package = __PACKAGE__;

role Type {
    use Carp;
    # required parameters
    field $signature :param :accessor;
    field $value     :param :accessor;

    # internal control
    field $encoded_value :accessor;

    # external methods
    method encode;
    method is_dynamic;

=head2 get_fixed_size_from_signature

Filter out the base type size (eg. int256 = 256)

=back

Returns the unsigned integer base type size or undef

=cut

    method get_fixed_size_from_signature() {
        $self->signature =~ /^(?:[a-z]+)(\d+)?/;
        return $1;
    }

=head2 get_base_signature

Filter out the base type (eg. int/string/bytes) from the type signature

=back

Returns the base type string or undef

=cut

    method get_base_signature() {
        $self->signature =~ /^([a-z]+(\d+)?)/;
        return $1;
    }

=head2 encode_integer

Encode the given unsigned integer to an 32 bytes padded left hexadecimal

=over 4

=item C<$value> unsigned integer to be encoded

=back

Returns 32 bytes padded hexadecimal

=cut

    method encode_integer($value) {
        return sprintf("%064s", sprintf("%x", $value));
    }

=head2 encode_offset

Encode the given unsigned integer to an 32 bytes padded left hexadecimal

This function will multiple the value by 32 to fit the ABI line length

=over 4

=item C<$value> unsigned integer to be encoded

=back

Returns 64 bytes padded hexadecimal

=cut

    method encode_offset($value) {
        return $self->encode_integer($value * 32);
    }

=head2 get_instance

Based on the give type signature finds the reference module to handle the type encoding

=over 4

=item C<$signature> type signature

=item C<$value> type value

=back

Returns a L<REFECO::Blockchain::SmartContracts::Solidity::ABI::Type> based instance for the given type

=cut

    method get_instance :common :($signature, $value) {
        my $package;
        if ($signature =~ /\[(\d+)?\]/gm) {
            $package = "Array";
        } elsif ($signature =~ /^address$/) {
            $package = "Address";
        } elsif ($signature =~ /^(u)?(int|bool)(\d+)?$/) {
            $package = "Int";
        } elsif ($signature =~ /^(?:bytes)(\d+)?$/) {
            $package = "Bytes";
        } elsif ($signature =~ /^string$/) {
            $package = "String";
        } else {
            croak "Module not found for the given parameter signature";
        }

        # this is just to avoid `use module` for every new type included
        (my $path = $_package) =~ s|::|/|g;
        my $package_file = sprintf("%s/%s.pm", $path, $package);
        require $package_file;
        $package->import();
        return $package->new(
            signature => $signature,
            value     => $value,
        );
    }

}

1;

