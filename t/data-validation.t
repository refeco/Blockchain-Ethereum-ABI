#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

use REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder;

my $encoder = REFECO::Blockchain::SmartContracts::Solidity::ABI::Encoder->new();

subtest "Array" => sub {
    like(
        exception { $encoder->append('uint[1]' => [1, 2, 3, 4])->encode },
        qr/Invalid array size, signature \d+, data: \d+/,
        "die correctly for invalid array size"
    );
    $encoder->clean;
};

subtest "Type" => sub {
    like(
        exception { $encoder->append(undef => [])->encode },
        qr/Module not found for the given parameter signature/,
        'die correctly for invalid signature'
    );
    $encoder->clean;
};

subtest "Numeric" => sub {
    like(exception { $encoder->append(int => [])->encode }, qr/Invalid numeric data/, 'die correctly for invalid numeric value');
    $encoder->clean;

    like(exception { $encoder->append(uint => -1)->encode }, qr/Invalid negative numeric data/, 'die correctly for negative uint numeric');
    $encoder->clean;

    like(exception { $encoder->append(bool => -1)->encode }, qr/Invalid negative numeric data/, 'die correctly for negative bool');
    $encoder->clean;

    like(exception { $encoder->append(bool => 2)->encode }, qr/Invalid bool data it must be 1 or 0 but given/,
        'die correctly for invalid bool value');
    $encoder->clean;

    like(
        exception { $encoder->append(uint32 => '3452432985703298457239498237458932')->encode },
        qr/Invalid data length, signature: \d+, data length: \d+/,
        'die correctly invailid length numeric'
    );
    $encoder->clean;
};

done_testing;

