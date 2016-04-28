#!/bin/sh

size="$1"
[ -z "$size" ] && size=10000

checksum=$(which md5 || which md5sum)

echo "Testing $size MB stream encoding/decoding. This may take a few minutes."
echo "Please enter the same password when asked."
../shenc --generate-key >key || { echo shenc --generate-key failed; exit 1; }
mkfifo fifo || { echo mkfifo failed;  exit 1; }
"$checksum" < fifo &
time dd if=/dev/zero bs=1000000 count=$size | tee fifo |  /bin/sh key | /bin/sh | "$checksum"
rm -f fifo key
