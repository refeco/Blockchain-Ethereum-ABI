package REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

use v5.26;
use strict;
use warnings;

=head1 NAME

REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder - Contract Application Binary Interface Encoder

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

The Contract Application Binary Interface (ABI) is the standard way to interact
with contracts (Ethereum), this module aims to be an utility to encode the given
data according ABI type specification.

    use REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

    my $encoder = Encoder->new();
    $encoder->append(name => 'transfer')->append(address => $address)->append(uint256 => $value)->encode();
    ...

=head1 AUTHOR

Reginaldo Costa, C<< <reginaldo at refeco.dev> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-refeco-blockchain-smartcontracts-solidity-abi-encoder at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder>

=item * Search CPAN

L<https://metacpan.org/release/REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Reginaldo Costa.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

use Object::Pad;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

class Encoder {
    use Carp;
    use Digest::Keccak qw(keccak_256_hex);
    field @function_params;
    field $function_name :accessor;

=head2 append

Includes a new instance for the given type signature

=over 4

=item C<%param> containing the key as the type signature and the value as the value

=back

Returns $self

=cut

    method append(%param) {
        for my $type_signature (keys %param) {
            push(@function_params, Type->get_instance($type_signature, $param{$type_signature}));
        }

        return $self;
    }

=head2 function

Set the function name

=over 4

=item C<$item> function name

=back

=cut

    method function($name) {
        $self->function_name($name);
        return $self;
    }

=head2 generate_function_signature

Using the given appended values generate the function signature

=over 4

=back

Returns the function signature string

=cut

    method generate_function_signature() {
        croak "Missing function name" unless $self->function_name;
        # this method requires the function name to be set
        my $signature = $self->function_name . '(';
        $signature .= sprintf("%s,", $_->signature) for @function_params;
        chop $signature;
        return $signature . ')';
    }

=head2 encode_function_signature

Encode the function signature using SHA256

=over 4

=back

Return the first 4 bytes from the SHA256 encoded function signature string

=cut

    method encode_function_signature() {
        return sprintf("0x%.8s", keccak_256_hex($self->generate_function_signature));
    }

=head2 encode

Encode all appended types in a single ABI encoded string

=over 4

=back

Returns an ABI encoded string

=cut

    method encode() {
        my (@static, @dynamic);
        # if the function name is given includes it to the encoded string
        push @static, $self->encode_function_signature() if $self->function_name;
        # the initial offset is important as all the dynamic values will
        # depend on this info to set their offset
        my $offset = $self->get_initial_position();
        for my $param (@function_params) {
            $param->encode();
            # for dynamic items the offset must be included
            if ($param->is_dynamic) {
                push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
                push @dynamic, $param->encoded_value;
                # 64 characters = 32 bytes
                $offset += length($param->encoded_value) / 64;
            } else {
                # static items require only the encoded value
                push @static, $param->encoded_value;
            }
        }
        my @data = (@static, @dynamic);
        return join('', @data);
    }

=head2 get_initial_position

Calculate the initial offset position for the given appended types

The offset here is just the unsigned integer space that the static parameters
will require, it will need to be set to an 32 bytes hexadecimal to be included

=over 4

=back

Returns the unsigned integer position for the offset start

=cut

    method get_initial_position() {
        my $offset = 0;
        for my $param (@function_params) {
            # if the function is an array with a fixed size, the count
            # needs to be included in the offset
            if (!$param->is_dynamic && $param->isa('Array')) {
                $offset += $param->get_array_size_from_signature();
                next;
            }
            # if is not an array 1 as default size
            $offset += 1;
        }

        return $offset;
    }

}

1;    # End of REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder
