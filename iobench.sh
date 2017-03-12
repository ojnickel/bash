#! /bin/bash
echo "Write:"
sync; dd if=/dev/zero of=~/test.tmp bs=500K count=1024

echo -e "\nRead:"
sync; echo 3 | tee /proc/sys/vm/drop_caches
sync; time dd if=~/test.tmp of=/dev/null bs=500K count=1024

rm ~/test.tmp
