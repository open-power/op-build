#!/bin/bash

dd if=hw_key_a.pem bs=1c skip=1 > a
dd if=hw_key_b.pem bs=1c skip=1 > b
dd if=hw_key_c.pem bs=1c skip=1 > c

cat a b c > combined.keys

echo
echo "SHA512 combined key hash:"
sha512sum combined.keys 

rm a b c combined.keys
