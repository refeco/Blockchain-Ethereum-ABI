use v5.26;
use Object::Pad;

role Blockchain::Ethereum::ABI::TypeRole {
    method encode;
    method decode;
    method _configure;
};

1;
