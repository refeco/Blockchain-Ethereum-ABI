package Blockchain::Ethereum::ABI::Type;

use v5.26;
use strict;
use warnings;

use Carp;
use Module::Load;
use constant NOT_IMPLEMENTED => 'Method not implemented';

sub new {
    my ($class, %params) = @_;

    my $self = bless {}, $class;
    $self->{signature} = $params{signature};
    $self->{data}      = $params{data};

    $self->_configure;

    return $self;
}

# to be implemented by the child classes that need it
sub _configure { }

sub encode {
    croak NOT_IMPLEMENTED;
}

sub decode {
    croak NOT_IMPLEMENTED;
}

sub _static {
    return shift->{static} //= [];
}

sub _push_static {
    my ($self, $data) = @_;
    push($self->_static->@*, ref $data eq 'ARRAY' ? $data->@* : $data);
}

sub _dynamic {
    return shift->{dynamic} //= [];
}

sub _push_dynamic {
    my ($self, $data) = @_;
    push($self->_dynamic->@*, ref $data eq 'ARRAY' ? $data->@* : $data);
}

sub _signature {
    return shift->{signature};
}

sub _data {
    return shift->{data};
}

sub fixed_length {
    my $self = shift;
    if ($self->_signature =~ /[a-z](\d+)/) {
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

sub _encode_length {
    my ($self, $length) = @_;
    return sprintf("%064s", sprintf("%x", $length));
}

sub _encode_offset {
    my ($self, $offset) = @_;
    return sprintf("%064s", sprintf("%x", $offset * 32));
}

sub _encoded {
    my $self = shift;
    my @data = ($self->_static->@*, $self->_dynamic->@*);
    return scalar @data ? \@data : undef;
}

sub is_dynamic {
    return shift->_signature =~ /(bytes|string)(?!\d+)|(\[\])/ ? 1 : 0;
}

sub new_type {
    my ($self, %params) = @_;

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

sub _instances {
    return shift->{instances} //= [];
}

# get the first index where data is set to the encoded value
# skipping the prefixed indexes
sub _get_initial_offset {
    my $self   = shift;
    my $offset = 0;
    for my $param ($self->_instances->@*) {
        my $encoded = $param->encode;
        if ($param->is_dynamic) {
            $offset += 1;
        } else {
            $offset += scalar $param->_encoded->@*;
        }
    }

    return $offset;
}

sub _static_size {
    return 1;
}

# read the data at the encoded stack
sub _read_stack_set_data {
    my $self = shift;

    my @data = $self->_data->@*;
    my @offsets;
    my $current_offset = 0;

    # Since at this point we don't information about the chunks of data it is_dynamic
    # needed to get all the offsets in the static header, so the dynamic values can
    # be retrieved based in between the current and the next offsets
    for my $instance ($self->_instances->@*) {
        if ($instance->is_dynamic) {
            push @offsets, hex($data[$current_offset]) / 32;
        }

        my $size = 1;
        $size = $instance->_static_size unless $instance->is_dynamic;
        $current_offset += $size;
    }

    $current_offset = 0;
    my %response;
    # Dynamic data must to be set first since the full_size method
    # will need to use the data offset related to the size of the item
    for (my $i = 0; $i < $self->_instances->@*; $i++) {
        my $instance = $self->_instances->[$i];
        next unless $instance->is_dynamic;
        my $offset_start = shift @offsets;
        my $offset_end   = $offsets[0] // scalar @data - 1;
        my @range        = @data[$offset_start .. $offset_end];
        $instance->{data} = \@range;
        $current_offset += scalar @range;
        $response{$i} = $instance->decode();
    }

    $current_offset = 0;

    for (my $i = 0; $i < $self->_instances->@*; $i++) {
        my $instance = $self->_instances->[$i];

        if ($instance->is_dynamic) {
            $current_offset++;
            next;
        }

        my $size = 1;
        $size = $instance->_static_size unless $instance->is_dynamic;
        my @range = @data[$current_offset .. $current_offset + $size - 1];
        $instance->{data} = \@range;
        $current_offset += $size;

        $response{$i} = $instance->decode();
    }

    my @array_response;
    # the given order of type signatures needs to be strict followed
    push(@array_response, $response{$_}) for 0 .. scalar $self->_instances->@* - 1;
    return \@array_response;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Type - Interface for solidity variable types

=head1 SYNOPSIS

Allows you to define and instantiate a solidity variable type:

    my $type = Blockchain::Ethereum::ABI::Type->new;
    $type->new_type(
        signature => $signature,
        data      => $value
    );

    $type->encode();
    ...

In most cases you don't want to use this directly, use instead:

=over 4

=item * B<Encoder>: L<Blockchain::Ethereum::ABI::Encoder>

=item * B<Decoder>: L<Blockchain::Ethereum::ABI::Decoder>

=back

=head1 METHODS

=head2 new_type

Create a new L<Blockchain::Ethereum::ABI::Type> instance based
in the given signature.

Usage:

    new_type(signature => signature, data => value) -> L<Blockchain::Ethereum::ABI::Type::*>

=over 4

=item * C<%params> signature and data key values

=back

Returns an new instance of one of the sub modules for L<Blockchain::Ethereum::ABI::Type>

=head2 encode

Encodes the given data to the type of the signature

Usage:

    encode() -> encoded string

=over 4

=back

=head2 decode

Decodes the given data to the type of the signature

Usage:

    decoded() -> check the child classes for return type

=over 4

=back

check the child classes for return type

=head2 fixed_length

Check if that is a length specified for the given signature

Usage:

    fixed_length() -> integer length or undef

=over 4

=back

Integer length or undef in case of no length specified

=head2 pad_right

Pads the given data to right 32 bytes with zeros

Usage:

    pad_right("1") -> "100000000000..0"

=over 4

=item * C<$data> data to be padded

=back

Returns the padded string

=head2 pad_left

Pads the given data to left 32 bytes with zeros

Usage:

    pad_left("1") -> "0000000000..1"

=over 4

=item * C<$data> data to be padded

=back

Returns the padded string

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Type

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
