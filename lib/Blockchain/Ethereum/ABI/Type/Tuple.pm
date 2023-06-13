package Blockchain::Ethereum::ABI::Type::Tuple;

use v5.26;
use strict;
use warnings;

use Carp;
use parent qw(Blockchain::Ethereum::ABI::Type);

sub _configure {
    my $self = shift;
    return unless $self->_data;

    my @splited_signatures = $self->_split_tuple_signature->@*;

    for (my $sig_index = 0; $sig_index < @splited_signatures; $sig_index++) {
        push $self->_instances->@*,
            Blockchain::Ethereum::ABI::Type::new_type(
            signature => $splited_signatures[$sig_index],
            data      => $self->_data->[$sig_index]);
    }

}

sub _split_tuple_signature {
    my $self             = shift;
    my $tuple_signatures = substr($self->_signature, 1, length($self->_signature) - 2);
    $tuple_signatures =~ s/((\((?>[^)(]*(?2)?)*\))|[^,()]*)(*SKIP),/$1\n/g;
    my @types = split('\n', $tuple_signatures);
    return \@types;
}

sub encode {
    my $self = shift;
    return $self->_encoded if $self->_encoded;

    my $offset = $self->_get_initial_offset;

    for my $instance ($self->_instances->@*) {
        $instance->encode;
        if ($instance->is_dynamic) {
            $self->_push_static($self->_encode_offset($offset));
            $self->_push_dynamic($instance->_encoded);
            $offset += scalar $instance->_encoded->@*;
            next;
        }

        $self->_push_static($instance->_encoded);
    }

    return $self->_encoded;
}

sub decode {
    my $self = shift;

    unless (scalar $self->_instances->@* > 0) {
        push $self->_instances->@*, Blockchain::Ethereum::ABI::Type::new_type(signature => $_) for $self->_split_tuple_signature->@*;
    }

    return $self->_read_stack_set_data;
}

sub _static_size {
    my $self = shift;
    return 1 if $self->is_dynamic;
    my $size          = 1;
    my $instance_size = 0;
    for my $signature ($self->_split_tuple_signature->@*) {
        my $instance = Blockchain::Ethereum::ABI::Type::new_type(signature => $signature);
        $instance_size += $instance->_static_size // 0;
    }

    return $size * $instance_size;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Tuple - Interface for solidity tuple type

=head1 SYNOPSIS

Allows you to define and instantiate a solidity tuple type:

    my $type = Blockchain::Ethereum::ABI::Tuple->new(
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

    perldoc Blockchain::Ethereum::ABI::Tuple

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut