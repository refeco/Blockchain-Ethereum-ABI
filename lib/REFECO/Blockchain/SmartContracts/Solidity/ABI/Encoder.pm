package REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

use strict;
use warnings;
no indirect;

=head1 NAME

REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder - Contract Application Binary Interface Encoder

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

The Contract Application Binary Interface (ABI) is the standard way to interact
with contracts (Ethereum), this module aims to be an utility to encode the given
data according ABI type specification.

    my $encoder = REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder->new();
    $encoder->function('test')
        # string
        ->append(string => 'Hello, World!')
        # bytes
        ->append(bytes => unpack("H*", 'Hello, World!'))
        # tuple
        ->append('(uint256,address)' => [75000000000000, '0x0000000000000000000000000000000000000000'])
        # arrays
        ->append('bool[]', [1, 0, 1, 0])
        # multidimensional arrays
        ->append('uint256[][][2]', [[[1]], [[2]]])
        # tuples arrays and tuples inside tuples
        ->append('((int256)[2])' => [[[1], [2]]])->encode();
    ...

=head1 AUTHOR

Reginaldo Costa, C<< <reginaldo at cpan.org> >>

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

use Carp;
use Digest::Keccak qw(keccak_256_hex);
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub instances {
    my $self = shift;
    return $self->{instances} //= [];
}

sub function_name {
    my $self = shift;
    return $self->{function_name};
}

sub append {
    my ($self, %param) = @_;

    for my $type_signature (keys %param) {
        push(
            $self->instances->@*,
            REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(
                signature => $type_signature,
                data      => $param{$type_signature}));
    }

    return $self;
}

sub function {
    my ($self, $function_name) = @_;
    $self->{function_name} = $function_name;
    return $self;
}

sub generate_function_signature {
    my $self = shift;
    croak "Missing function name eg. ->function('name')" unless $self->function_name;
    my $signature = $self->function_name . '(';
    $signature .= sprintf("%s,", $_->signature) for $self->instances->@*;
    chop $signature;
    return $signature . ')';
}

sub encode_function_signature {
    my ($self, $signature) = @_;
    return sprintf("0x%.8s", keccak_256_hex($signature // $self->generate_function_signature));
}

sub encode {
    my $self = shift;
    my (@static, @dynamic);

    push @static, $self->encode_function_signature()
        if $self->function_name;

    my $offset = $self->get_initial_offset();

    for my $param ($self->instances->@*) {
        my $encoded = join('', $param->encode->@*);
        # for dynamic items the offset must be included
        if ($param->is_dynamic) {
            push @static,  sprintf("%064s", sprintf("%x", $offset * 32));
            push @dynamic, $encoded;
            $offset += scalar $param->encode->@*;
        } else {
            # static items require only the encoded value
            push @static, $encoded;
        }
    }

    my @data = (@static, @dynamic);
    return join('', @data);
}

sub get_initial_offset {
    my $self   = shift;
    my $offset = 0;
    for my $param ($self->instances->@*) {
        my $encoded = $param->encode();
        if ($param->is_dynamic) {
            $offset += 1;
        } else {
            $offset += scalar $param->encoded->@*;
        }
    }

    return $offset;
}

sub clear {
    my $self = shift;
    delete $self->{instances};
    undef $self->{function_name};
}

1;

