#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use REFECO::Blockchain::Contract::Solidity::ABI::Encoder;

my $encoder = REFECO::Blockchain::Contract::Solidity::ABI::Encoder->new();

subtest 'Tuples, Sub tuples, tuples arrays' => sub {
    $encoder->function('fulfillBasicOrder')->append(
        '(address,uint256,uint256,address,address,address,uint256,uint256,uint8,uint256,uint256,bytes32,uint256,bytes32,bytes32,uint256,(uint256,address)[],bytes)'
            => [
            '0x0000000000000000000000000000000000000000',
            0,
            2850000000000000,
            '0x5E9988B0C47B47A5b1d7D2E65358789044C2eF9a',
            '0x004C00500000aD104D7DBd00e3ae0A5C00560C00',
            '0x2Cc8342d7c8BFf5A213eb2cdE39DE9a59b3461A7',
            45981, 1, 2,
            1664873641,
            1667544153,
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            '24446860302761739304752683030156737591518664810215442929812187193154675427388',
            '0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000',
            '0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000',
            3,
            [
                [75000000000000, '0x0000a26b00c1F0DF003000390027140000fAa719'],
                [30000000000000, '0x2Dc05E282a6829c66e91b655F91129800Fb9DBDF'],
                [45000000000000, '0x2a1De3F4582BB617225e32922Ba789693156FC8C']
            ],
            '0xd410c95bb9d3f04cb0c2340a5fa890e506c2d9159aadd8bf06bcd03e56a9f48c44115a13a2f9fc6184cfe40747ebff2da100329aa385fa19de112ed2f3ed11731b'
            ]);

    my $encoded_etherscan =
        '0xfb0f3ee1000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a200f559c20000000000000000000000000005e9988b0c47b47a5b1d7d2e65358789044c2ef9a000000000000000000000000004c00500000ad104d7dbd00e3ae0a5c00560c000000000000000000000000002cc8342d7c8bff5a213eb2cde39de9a59b3461a7000000000000000000000000000000000000000000000000000000000000b39d0000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000633bf4a9000000000000000000000000000000000000000000000000000000006364b4590000000000000000000000000000000000000000000000000000000000000000360c6ebe0000000000000000000000000000000000000000a3d2067fd6a0483c0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f00000000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f00000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000024000000000000000000000000000000000000000000000000000000000000003200000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000044364c5bb0000000000000000000000000000000a26b00c1f0df003000390027140000faa71900000000000000000000000000000000000000000000000000001b48eb57e0000000000000000000000000002dc05e282a6829c66e91b655f91129800fb9dbdf000000000000000000000000000000000000000000000000000028ed6103d0000000000000000000000000002a1de3f4582bb617225e32922ba789693156fc8c0000000000000000000000000000000000000000000000000000000000000041d410c95bb9d3f04cb0c2340a5fa890e506c2d9159aadd8bf06bcd03e56a9f48c44115a13a2f9fc6184cfe40747ebff2da100329aa385fa19de112ed2f3ed11731b00000000000000000000000000000000000000000000000000000000000000';

    is(lc $encoder->encode, lc $encoded_etherscan, 'https://etherscan.io/tx/0x5f38348937b9fedd3e2463c47eb6575c8f9189cbbbec70e4eec66fabdac7394f');
    $encoder->clean;

};

subtest 'Big bytes' => sub {
    my $encoded = $encoder->function('multicall')->append('uint256' => 1665397175)->append(
        'bytes[]' => [
            '0xb858183f000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000c7f7b0952a362b0000000000000000000000000000000000000000000000000000000b3838e51b9ed28000000000000000000000000000000000000000000000000000000000000004206450dee7fd2fb8e39061434babcfc05599a6fb8002710a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000bb8c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2000000000000000000000000000000000000000000000000000000000000',
            '0x49404b7c00000000000000000000000000000000000000000000000000b3838e51b9ed2800000000000000000000000068eea64d9794cbe154dfd511ed038d612451ed1d'
        ])->encode;

    my $encoded_etherscan =
        '0x5ae401dc000000000000000000000000000000000000000000000000000000006343f1b700000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000001a00000000000000000000000000000000000000000000000000000000000000124b858183f000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000c7f7b0952a362b0000000000000000000000000000000000000000000000000000000b3838e51b9ed28000000000000000000000000000000000000000000000000000000000000004206450dee7fd2fb8e39061434babcfc05599a6fb8002710a0b86991c6218b36c1d19d4a2e9eb0ce3606eb48000bb8c02aaa39b223fe8d0a0e5c4f27ead9083c756cc200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000004449404b7c00000000000000000000000000000000000000000000000000b3838e51b9ed2800000000000000000000000068eea64d9794cbe154dfd511ed038d612451ed1d00000000000000000000000000000000000000000000000000000000';

    is(lc $encoded, lc $encoded_etherscan, 'https://etherscan.io/tx/0x0974a6b398a8d3572f87c144db1813f232b39629b8bdb8da5e9acd8f020c15eb');
    $encoder->clean;
};

done_testing;

