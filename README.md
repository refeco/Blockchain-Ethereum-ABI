# solidity-abi-encoder

Solidity contracts ABI encoding utility

# Supports:

- address
- bool
- bytes(\d+)?
- (u)?int(\d+)?
- string

Also arrays `((\[(\d+)?\])+)?` for the above mentioned types.

# Examples:

```perl
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

my $encoder = Encoder->new();
$encoder->append(name => 'transfer')->append(address => $address)->append(uint256 => $value)->encode();
```

# Installation

## CPAN

```
cpanm REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder
```

## Make

```
perl Makefile.PL
make
make test
make install
```

# Support and Documentation

After installing, you can find documentation for this module with the
perldoc command.

```
perldoc REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder
```

You can also look for information at:

- [RT, CPAN's request tracker (report bugs here)](https://rt.cpan.org/NoAuth/Bugs.html?Dist=REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder )

- [CPAN Ratings](https://cpanratings.perl.org/d/REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder )

- [Search CPAN](https://metacpan.org/release/REFECO-Blockchain-SmartContracts-Solidity-ABI-Encoder)

# License and Copyright

This software is Copyright (c) 2022 by Reginaldo Costa.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)

