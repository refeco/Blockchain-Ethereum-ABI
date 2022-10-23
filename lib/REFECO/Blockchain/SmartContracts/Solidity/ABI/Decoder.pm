package REFECO::Blockchain::SmartContracts::Solidity::ABI::Decoder;

use strict;
use warnings;
no indirect;

our $VERSION = '0.001';

use Carp;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;
use REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Tuple;

sub new {
    my ($class, %params) = @_;

    my $self = {};
    bless $self, $class;
    return $self;
}

sub instances {
    my $self = shift;
    return $self->{instances} //= [];
}

sub data {
    my $self = shift;
    return $self->{data};
}

sub append {
    my ($self, $param) = @_;

    push $self->instances->@*, REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::new_type(signature => $param);
    return $self;
}

sub decode {
    my ($self, $hex_data) = @_;

    croak 'Invalid hexadecimal value ' . $hex_data // 'undef'
        unless $hex_data =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;

    my $hex  = $1;
    my @data = unpack("(A64)*", $hex);

    my $tuple = REFECO::Blockchain::SmartContracts::Solidity::ABI::Type::Tuple->new();
    $tuple->{instances} = $self->instances;
    $tuple->{data}      = \@data;
    return $tuple->decode;
}

sub clean {
    my $self = shift;
    delete $self->{instances};
}

1;

