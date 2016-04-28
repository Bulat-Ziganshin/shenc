#!/bin/sh

size="$1"
[ -z "$size" ] && size=1000000

echo "This program will test shenc using file of $size bytes"
echo "Please enter the same password when asked."

checksum=$(which md5 || which md5sum)

openssl rand $size >"input 1 0" || { echo openssl rand failed; exit 1; }
openssl rand $size >"input 2 0" || { echo openssl rand failed; exit 1; }

# generate key
../shenc --generate-key >"key 0" || { echo shenc --generate-key failed; exit 1; }

# encrypt
../shenc --encrypt "key 0" <"input 1 0" >"output 1 0" || { echo shenc --encrypt failed; exit 1; }
/bin/sh "key 0" <"input 2 0" >"output 2 0" || { echo /bin/sh key-file failed; exit 1; }

# decrypt
../shenc --decrypt <"output 1 0" >"input 1 1" || { echo shenc --decrypt failed; exit 1; }
/bin/sh "output 2 0" >"input 2 1" || { echo /bin/sh encrypted-file failed; exit 1; }
/bin/sh <"output 2 0" >"input 2 2" || { echo "/bin/sh <encrypted-file failed"; exit 1; }

# extract key
../shenc --extract-key <"output 1 0" >"key 1" || { echo "shenc --extract-key failed"; exit 1; }

echo "Check that the following checksums are the same"
"$checksum" "input 1 0" "input 1 1"
echo "Check that the following checksums are the same"
"$checksum" "input 2 0" "input 2 1" "input 2 2"
echo "Check that the following checksums are the same"
"$checksum" "key 0" "key 1"
echo "Press Ctrl+C to preserve generated files or Enter to remove files"
read
rm -f input* output* key*
