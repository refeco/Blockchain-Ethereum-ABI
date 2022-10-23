package REFECO::Blockchain::SmartContracts::Solidity::ABI::Decoder;

use strict;
use warnings;
no indirect;

=head1 NAME

REFECO::Blockchain::SmartContracts::Solidity::ABI::Decoder - Contract Application Binary Interface argument decoder

=head1 VERSION

Version 0.001

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

The Contract Application Binary Interface (ABI) is the standard way to interact
with contracts (Ethereum), this module aims to be an utility to encode the given
data according ABI type specification.

    my $decoder = REFECO::Blockchain::SmartContracts::Solidity::ABI::Decoder->new();
    $decoder
        ->append('uint256')
        ->append('bytes[]')
        ->decode('0x...');
    ...

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-refeco-blockchain-smartcontracts-solidity-abi-encoder at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc REFECO::Blockchain::SmartContracts::Solidity::ABI::Decoder


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
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Tuple;

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

sub data {
    my $self = shift;
    return $self->{data};
}

sub append {
    my ($self, $param) = @_;

    push $self->instances->@*, REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(signature => $param);
    return $self;
}

sub decode {
    my ($self, $hex_data) = @_;

    croak 'Invalid hexadecimal value ' . $hex_data // 'undef'
        unless $hex_data =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;

    my $hex  = $1;
    my @data = unpack("(A64)*", $hex);

    my $tuple = REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Tuple->new;
    $tuple->{instances} = $self->instances;
    $tuple->{data}      = \@data;
    return $tuple->decode;
}

sub clean {
    my $self = shift;
    delete $self->{instances};
}

1;

