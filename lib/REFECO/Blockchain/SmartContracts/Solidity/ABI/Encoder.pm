package REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

use v5.26;
use strict;
use warnings;

=head1 NAME

REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder - The great new REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

    my $foo = REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 function1

=cut

sub function1 {
}

=head2 function2

=cut

sub function2 {
}

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
    use Digest::Keccak qw(keccak_256_hex);
    field @function_params;
    field $function_name;

    method append(%param) {
        for my $type_signature (keys %param) {
            if ($type_signature eq 'name') {
                $function_name = $param{$type_signature};
                next;
            }
            push(@function_params, Type->get_instance($type_signature, $param{$type_signature}));
        }

        return $self;
    }

    method generate_function_signature() {
        my $signature = $function_name . '(';
        $signature .= sprintf("%s,", $_->signature) for @function_params;
        chop $signature;
        return $signature . ')';
    }

    method encode_function_signature() {
        return sprintf("0x%.8s", keccak_256_hex($self->generate_function_signature));
    }

    method encode() {
        my (@static, @dynamic);
        push @static, $self->encode_function_signature() if $function_name;
        my $offset = $self->get_initial_position();
        for my $param (@function_params) {
            $param->encode();
            if ($param->is_dynamic) {
                push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
                push @dynamic, $param->encoded_value;
                $offset += length($param->encoded_value) / 64;
            } else {
                push @static, $param->encoded_value;
            }
        }
        my @data = (@static, @dynamic);
        return join('', @data);
    }

    method get_initial_position() {
        my $offset = 0;
        for my $param (@function_params) {
            if (!$param->is_dynamic && $param->isa('Array')) {
                $offset += $param->get_array_size_from_signature();
                next;
            }
            $offset += 1;
        }

        return $offset;
    }

}

1;    # End of REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder
