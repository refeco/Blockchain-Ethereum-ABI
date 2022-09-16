#!/usr/bin/env perl

use strict;
use warnings;
no indirect;

use Data::Dumper;
use REFECO::Blockchain::Ethereum::ABI;

my $abi = ABI->new();
# print Dumper $abi->encode_function_signature(signature => 'myMethod(uint256,string)');
# print Dumper $abi->encode_event_signature(signature => 'myEvent(uint256,bytes32)');
# print Dumper $abi->encode_parameter(
#     type  => 'bytes8',
#     value => '0x123'
# );
print Dumper $abi->encode('bool', 1);
# print Dumper $abi->encode_parameter(
#     type  => 'string[2][2]',
#     value => [["a", "b"], ["a", "b"]]);
# print Dumper $abi->split_function_signature(signature => 'transfer(address _to, uint256 _value)');
# print Dumper $abi->generate_function_selector(signature => 'transfer(address _to, uint256 _value)');
# $abi->encode(
#     signature => 'transfer(address _to, uint256[2][] _value)',
#     values    => ['0x00000000006c3852cbEf3e08E8dF289169EdE581', [[0, 1], [0, 1]]]);

# print $abi->encode_signature(
#     signature => 'transfer(address _to, uint256[8] _value)',
#     args      => ['0x00000000006c3852cbEf3e08E8dF289169EdE581', 10]);

