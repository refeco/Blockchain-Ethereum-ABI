#!/usr/bin/env perl

use strict;
use warnings;
no indirect;

use Data::Dumper;
use REFECO::Blockchain::Ethereum::ABI;

my $abi = ABI->new();

# print Dumper $abi->append(bytes32 => '0x01')->append(string => 'papo reto')->encode();
# print Dumper $abi->append("string[]" => 'agata')->append(bytes => "0x1262")->append(string => 'agata')->encode();
print Dumper $abi->append("uint256[]" => [[1, 2], [3]])->append("string[]" => ["one", "two", "three"])->encode();
# print Dumper $abi->append("uint256[][]" => [[1, 2], [3]])->encode();
