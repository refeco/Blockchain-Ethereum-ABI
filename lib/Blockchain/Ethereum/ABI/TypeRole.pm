use v5.26;
use Object::Pad;

package Blockchain::Ethereum::ABI::TypeRole 0.010;
role Blockchain::Ethereum::ABI::TypeRole {
    method encode;
    method decode;
    method _configure;
};

1;
