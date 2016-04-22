#!/bin/sh

size="$1"
[ -z "$size" ] && size=10000

checksum=$(which md5 || which md5sum)

echo "Testing $size MB stream encoding/decoding. This may take a few minutes."
echo "Please enter the same password when asked."
mkfifo fifo
"$checksum" < fifo &
time dd if=/dev/zero bs=1000000 count=$size | tee fifo |  ../shenc | /bin/sh | "$checksum"
rm fifo
