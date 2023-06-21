package Blockchain::Ethereum::ABI::Type::Array;

use v5.26;
use strict;
use warnings;

use Carp;
use parent qw(Blockchain::Ethereum::ABI::Type);

sub _configure {
    my $self = shift;
    return unless $self->_data;

    for my $item ($self->_data->@*) {
        push $self->_instances->@*,
            $self->new_type(
            signature => $self->_remove_parent,
            data      => $item
            );
    }
}

sub encode {
    my $self = shift;
    return $self->_encoded if $self->_encoded;

    my $length = scalar $self->_data->@*;
    # for dynamic length arrays the length must be included
    $self->_push_static($self->_encode_length($length))
        unless $self->fixed_length;

    croak "Invalid array size, signature @{[$self->fixed_length]}, data: $length"
        if $self->fixed_length && $length > $self->fixed_length;

    my $offset = $self->_get_initial_offset;

    for my $instance ($self->_instances->@*) {
        $self->_push_static($self->_encode_offset($offset))
            if $instance->is_dynamic;

        $self->_push_dynamic($instance->encode);
        $offset += scalar $instance->encode()->@*;
    }

    return $self->_encoded;
}

sub decode {
    my $self = shift;
    my @data = $self->_data->@*;

    my $size = $self->fixed_length // shift $self->_data->@*;
    push $self->_instances->@*, $self->new_type(signature => $self->_remove_parent) for 0 .. $size - 1;

    return $self->_read_stack_set_data;
}

sub _remove_parent {
    my $self = shift;
    $self->_signature =~ /(\[(\d+)?\]$)/;
    return substr $self->_signature, 0, length($self->_signature) - length($1 // '');
}

sub fixed_length {
    my $self = shift;
    if ($self->_signature =~ /\[(\d+)?\]$/) {
        return $1;
    }
    return undef;
}

sub _static_size {
    my $self = shift;
    return 1 if $self->is_dynamic;

    my $size = $self->fixed_length;

    my $instance_size = 1;
    for my $instance ($self->_instances->@*) {
        $instance_size += $instance->_static_size;
    }

    return $size * $instance_size;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Array - Interface for solidity array type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity tuple type:

    my $type = Blockchain::Ethereum::ABI::Array->new(
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

=head2 encode

Encodes the given data to the type of the signature

Usage:

    encode() -> encoded string

=over 4

=back

=head2 decode

Decodes the given data to the type of the signature

Usage:

    decoded() -> array reference

=over 4

=back

Array reference

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Array

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut
