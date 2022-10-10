package REFECO::Blockchain::SmartContracts::Solidity::ABI::Type;

use strict;
use warnings;
no indirect;

our $VERSION = '0.001';

use Carp;
use Module::Load;
use constant NOT_IMPLEMENTED => 'Method not implemented';

sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;
    $self->{signature} = $params{signature};
    $self->{data}      = $params{data};

    $self->configure();

    return $self;
}

sub configure { }

sub static {
    return shift->{static} //= [];
}

sub push_static {
    my ($self, $data) = @_;
    push($self->static->@*, ref $data eq 'ARRAY' ? $data->@* :$data);
}

sub dynamic {
    return shift->{dynamic} //= [];
}

sub push_dynamic {
    my ($self, $data) = @_;
    push($self->dynamic->@*, ref $data eq 'ARRAY' ? $data->@* :$data);
}

sub signature {
    return shift->{signature};
}

sub data {
    return shift->{data};
}

sub fixed_length {
    my $self = shift;
    if ($self->signature =~ /[a-z](\d+)/) {
        return $1;
    }
    return undef;
}

sub pad_right {
    my ($self, $data) = @_;

    my @chunks;
    push(@chunks, $_ . '0' x (64 - length $_)) for unpack("(A64)*", $data);

    return \@chunks;
}

sub pad_left {
    my ($self, $data) = @_;

    my @chunks;
    push(@chunks, sprintf("%064s", $_)) for unpack("(A64)*", $data);

    return \@chunks;

}

sub encode_length {
    my ($self, $length) = @_;
    return sprintf("%064s", sprintf("%x", $length));
}

sub encode_offset {
    my ($self, $offset) = @_;
    return sprintf("%064s", sprintf("%x", $offset * 32));
}

sub encoded {
    my $self = shift;
    my @data = ($self->static->@*, $self->dynamic->@*);
    return scalar @data ? \@data :undef;
}

sub is_dynamic {
    return shift->signature =~ /(bytes|string)(?!\d+)|(\[\])/ ? 1 :0;
}

sub new_type {
    my (%params) = @_;

    my $signature = $params{signature};

    my $module;
    if ($signature =~ /\[(\d+)?\]$/gm) {
        $module = "Array";
    } elsif ($signature =~ /^\(.*\)/) {
        $module = "Tuple";
    } elsif ($signature =~ /^address$/) {
        $module = "Address";
    } elsif ($signature =~ /^(u)?(int|bool)(\d+)?$/) {
        $module = "Int";
    } elsif ($signature =~ /^(?:bytes)(\d+)?$/) {
        $module = "Bytes";
    } elsif ($signature =~ /^string$/) {
        $module = "String";
    } else {
        croak "Module not found for the given parameter signature $signature";
    }

    # this is just to avoid `use module` for every new type included
    my $_package = __PACKAGE__;
    my $package  = sprintf("%s::%s", $_package, $module);
    load $package;
    return $package->new(
        signature => $signature,
        data      => $params{data});
}

1;

