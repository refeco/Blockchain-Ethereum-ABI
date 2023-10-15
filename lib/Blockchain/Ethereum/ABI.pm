use v5.26;
use Object::Pad;
# ABSTRACT: ABI utility for encoding/decoding ethereum contract arguments

package Blockchain::Ethereum::ABI;
class Blockchain::Ethereum::ABI;

# AUTHORITY
# VERSION

=head1 OVERVIEW

The Contract Application Binary Interface (ABI) is the standard way to interact
with contracts (Ethereum), this module aims to be an utility to encode/decode the given
data according ABI type specification.

Supports:

- address
- bool
- bytes(\d+)?
- (u)?int(\d+)?
- string
- tuple

Also arrays `((\[(\d+)?\])+)?` for the above mentioned types.

=head1 SYNOPSIS

    my $encoder = Blockchain::Ethereum::ABI::Encoder->new();
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
        ->append('((int256)[2])' => [[[1], [2]]])->encode;

    my $decoder = Blockchain::Ethereum::ABI::Decoder->new();
    $decoder
        ->append('uint256')
        ->append('bytes[]')
        ->decode('0x...');

=cut

1;
