use v5.26;

use strict;
use warnings;
no indirect;
use feature 'signatures';

use Object::Pad;
# ABSTRACT: Type interface roles

package Blockchain::Ethereum::ABI::TypeRole;
role Blockchain::Ethereum::ABI::TypeRole;

# AUTHORITY
# VERSION

=method encode

Encodes the given data to the type of the signature

=over 4

=back

ABI encoded hex string

=cut

method encode;

=method decode

Decodes the given data to the type of the signature

=over 4

=back

check the child classes for return type

=cut

method decode;

method _configure;

1;
