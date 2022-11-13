package REFECO::Blockchain::Contract::Solidity::ABI::Encoder;

use v5.26;
use strict;
use warnings;
no indirect;

use Carp;
use Digest::Keccak qw(keccak_256_hex);

use REFECO::Blockchain::Contract::Solidity::ABI::Type;
use REFECO::Blockchain::Contract::Solidity::ABI::Type::Tuple;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub _instances {
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
            $self->_instances->@*,
            REFECO::Blockchain::Contract::Solidity::ABI::Type::new_type(
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
    croak "Missing function name e.g. ->function('name')" unless $self->function_name;
    my $signature = $self->function_name . '(';
    $signature .= sprintf("%s,", $_->signature) for $self->_instances->@*;
    chop $signature;
    return $signature . ')';
}

sub encode_function_signature {
    my ($self, $signature) = @_;
    return sprintf("0x%.8s", keccak_256_hex($signature // $self->generate_function_signature));
}

sub encode {
    my $self = shift;

    my $tuple = REFECO::Blockchain::Contract::Solidity::ABI::Type::Tuple->new;
    $tuple->{instances} = $self->_instances;
    my @data = $tuple->encode->@*;
    unshift @data, $self->encode_function_signature if $self->function_name;

    $self->_clean;

    return join('', @data);
}

sub _clean {
    my $self = shift;
    delete $self->{instances};
    undef $self->{function_name};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

REFECO::Blockchain::Contract::Solidity::ABI::Encoder - Contract ABI argument encoder

=head1 SYNOPSIS

Allows you to encode contract ABI arguments

    my $encoder = REFECO::Blockchain::Contract::Solidity::ABI::Encoder->new();
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

=head1 METHODS

=head2 append

Appends type signature and the respective values to the encoder.

Usage:
    append(signature => value) -> L<REFECO::Blockchain::Contract::Solidity::ABI::Encoder>

=over 4

=item * C<%param> key is the respective type signature followed by the value e.g. uint256 => 10

=back

Returns C<$self>

=head2 function

Appends the function name to the encoder, this is optional for when you want the
function signature added to the encoded string or only the function name encoded.

Usage:
    function(string) -> L<REFECO::Blockchain::Contract::Solidity::ABI::Encoder>

=over 4

=item * C<function_name> solidity function name e.g. for `transfer(address,uint256)` will be `transfer`

=back

Returns C<$self>

=head2 generate_function_signature

Based on the given function name and type signatures create the complete function
signature

Usage:
    generate_function_signature() -> string

=over 4

=back

Returns the function signature string

=head2 encode_function_signature

Encode function signature keccak_256/sha3

Usage:
    encode_function_signature('transfer(address,uint)') -> encoded string

=over 4

=item C<signature> function signature, if not given, will try to use the appended function name

=back

Returns encoded string 0x prefixed

=head2 encode

Encodes appended signatures and the function name (when given)

=over 4

=back

Returns encoded string, if function name given will be 0x prefixed

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc REFECO::Blockchain::Contract::Solidity::ABI::Encoder

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by Reginaldo Costa.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

=cut
