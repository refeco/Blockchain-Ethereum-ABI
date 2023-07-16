use v5.26;
use Object::Pad ':experimental(init_expr)';

class Blockchain::Ethereum::ABI::Decoder {
    use Carp;
    use Blockchain::Ethereum::ABI::Type;
    use Blockchain::Ethereum::ABI::Type::Tuple;

    field $_instances :reader(_instances) :writer(set_instances) = [];

    method append ($param) {

        push $self->_instances->@*, Blockchain::Ethereum::ABI::Type->new(signature => $param);
        return $self;
    }

    method decode ($hex_data) {

        croak 'Invalid hexadecimal value ' . $hex_data // 'undef'
            unless $hex_data =~ /^(?:0x|0X)?([a-fA-F0-9]+)$/;

        my $hex  = $1;
        my @data = unpack("(A64)*", $hex);

        my $tuple = Blockchain::Ethereum::ABI::Type::Tuple->new;
        $tuple->set_instances($self->_instances);
        $tuple->set_data(\@data);
        my $data = $tuple->decode;

        $self->_clean;
        return $data;
    }

    method _clean {

        $self->set_instances([]);
    }

};

=pod

=encoding UTF-8

=head1 NAME

Blockchain::Ethereum::ABI::Decoder - Contract ABI response decoder

=head1 SYNOPSIS

Allows you to decode contract ABI response

    my $decoder = Blockchain::Ethereum::ABI::Decoder->new();
    $decoder
        ->append('uint256')
        ->append('bytes[]')
        ->decode('0x...');
    ...

=head1 METHODS

=head2 append

Appends type signature to the decoder.

Usage:

    append(signature) -> L<Blockchain::Ethereum::ABI::Encoder>

=over 4

=item * C<$param> type signature e.g. uint256

=back

Returns C<$self>

=head2 decode

Decodes appended signatures

Usage:

    decode() -> []

=over 4

=back

Returns an array reference containing all decoded values

=head1 AUTHOR

Reginaldo Costa, C<< <refeco at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to L<https://github.com/refeco/perl-ABI>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Blockchain::Ethereum::ABI::Encoder

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2022 by REFECO.

This is free software, licensed under:

  The MIT License

=cut

1;
