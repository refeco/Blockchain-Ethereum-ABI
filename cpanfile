requires 'Digest::Keccak', '>= 0.05';
requires 'Math::BigInt',   '>= 1.999837';
requires 'Carp', '>= 1.50';
requires 'Module::Load', '>= 0.36';

on 'test' => sub {
    requires 'Test::More', '>= 0.98';
    requires 'Test::Fatal', '>= 0.016';
}
