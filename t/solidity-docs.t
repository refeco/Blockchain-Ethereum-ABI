#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use REFECO::Blockchain::Ethereum::ABI;

subtest "example baz" => sub {
    my $abi = ABI->new();
    $abi->append(name => 'baz')->append(uint32 => 69)->append(bool => 1);

    my $encoded_doc =
        '0xcdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001';

    is($abi->encode(), $encoded_doc);
};

subtest "example bar" => sub {
    my $abi = ABI->new();
    my @params;
    push @params, unpack("H*", 'abc');
    push @params, unpack("H*", 'def');

    $abi->append(name => 'bar')->append('bytes3[2]' => \@params);

    my $encoded_doc =
        '0xfce353f661626300000000000000000000000000000000000000000000000000000000006465660000000000000000000000000000000000000000000000000000000000';

    is $abi->encode(), $encoded_doc, 'correct result for bar example';
};

done_testing;

