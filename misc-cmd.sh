### VIM
# add letter/word at the beginning of each sentence
%s/^/'/g

# add letter/word at the end of each sentence
%s/$/'/g

####
sync; echo 1 > /proc/sys/vm/drop_caches
sync; echo 2 > /proc/sys/vm/drop_caches
sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a
swapon -a
