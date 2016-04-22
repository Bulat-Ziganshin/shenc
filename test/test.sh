#!/bin/sh

size="$1"
[ -z "$size" ] && size=1000000

echo "This program will test shenc using file of $size bytes"
echo "Please enter the same password when asked."

checksum=$(which md5 || which md5sum)

openssl rand $size > "input 1 0" || { echo openssl rand failed; exit 1; }
openssl rand $size > "input 2 0" || { echo openssl rand failed; exit 1; }
../shenc < "input 1 0" > "output 1 1" || { echo shenc failed; exit 1; }
../shenc "output 1 1" < "input 1 0" > "output 1 2" || { echo shenc failed; exit 1; }
../shenc "output 1 2" < "input 2 0" > "output 2 1" || { echo shenc failed; exit 1; }
/bin/sh "output 1 1" > "input 1 1" || { echo decrypting failed; exit 1; }
/bin/sh < "output 1 2" > "input 1 2" || { echo decrypting failed; exit 1; }
/bin/sh "output 2 1" > "input 2 1" || { echo decrypting failed; exit 1; }

echo "Check that the following checksums are the same"
"$checksum" "input 1 0" "input 1 1" "input 1 2"
echo "Check that the following checksums are the same"
"$checksum" "input 2 0" "input 2 1"
echo "Press Ctrl+C to preserve generated files or Enter to remove files"
read
rm -f input* output*
