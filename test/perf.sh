#!/bin/sh

size="$1"
[ -z "$size" ] && size=10000

echo "Testing $size MB stream encoding/decoding. This may take a few minutes."
echo "Please enter the same password when asked."
../shenc --generate-key >key || { echo shenc --generate-key failed; exit 1; }
time dd if=/dev/zero bs=1000000 count=$size | /bin/sh key | /bin/sh >/dev/null
