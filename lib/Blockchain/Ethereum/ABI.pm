package Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

=head1 NAME

Blockchain::Ethereum::ABI - Contract ABI utilities

=head1 VERSION

Version 0.010

=cut

our $VERSION = '0.010';

=head1 SYNOPSIS

The Contract Application Binary Interface (ABI) is the standard way to interact
with contracts (Ethereum), this module aims to be an utility to encode/decode the given
data according ABI type specification.

=over 4

=item * B<Encoder>: L<Blockchain::Ethereum::ABI::Encoder>

=item * B<Decoder>: L<Blockchain::Ethereum::ABI::Decoder>

=back

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=REFECO-Blockchain-Ethereum-ABI>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/REFECO-Blockchain-Ethereum-ABI>

=item * Search CPAN

L<https://metacpan.org/release/REFECO-Blockchain-Ethereum-ABI>

=back

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
