package REFECO::Blockchain::Ethereum::ABI;

use v5.26;
use strict;
use warnings;

use Object::Pad;

my $_package = __PACKAGE__;

class ABI {
    has $instances;

    method get_type_instance($type_signature) {
        $type_signature =~ /^([a-z]+)?/;
        my $package = ucfirst $1;
        return $instances->{$package} //= do {
            (my $path = $_package) =~ s|::|/|g;
            my $package_file = sprintf("%s/Type/%s.pm", $path, $package);

            require $package_file;
            $package->import();
            $instances->{$package} = $package->new();
            $instances->{$package};
        }
    }

    method encode($type_signature, $value) {
        return $self->get_type_instance($type_signature)->encode($type_signature, $value);
    }
}

1;

