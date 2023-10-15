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

=over 4

=item * B<Encoder>: L<Blockchain::Ethereum::ABI::Encoder>

=item * B<Decoder>: L<Blockchain::Ethereum::ABI::Decoder>

=back

=cut

1;
