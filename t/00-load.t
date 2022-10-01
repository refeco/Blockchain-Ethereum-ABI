#!perl
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder' ) || print "Bail out!\n";
}

diag( "Testing REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder $REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder::VERSION, Perl $], $^X" );
