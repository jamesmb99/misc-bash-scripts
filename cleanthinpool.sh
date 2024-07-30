#!/bin/bash

thinpool_dir=/opt/thinpool-maintenance
log_dir=/var/log/thinpool-maintenance
txt_file=stopped_containers.txt
log_file=thinpool_maintenance.log
cur_date=$(date +%F)

mkdir -p ${thinpool_dir}
mkdir -p ${log_dir}
mkdir -p ../logs

# Check if the file exists
# if it doesn't exist, create it
if [ -f "${thinpool_dir}/${txt_file}" ]; then
    mv ${thinpool_dir}/${txt_file} ${thinpool_dir}/logs/${cur_date}_${txt_file}
else
    touch ${thinpool_dir}/${txt_file}
fi

if [ -f "${log_dir}/${log_file}" ]; then
    mv ${log_dir}/${log_file} ${log_dir}/${cur_date}_${log_file}
fi

# redirects standard output (stdout) and standard error (stderr) to the log file
exec > ${log_dir}/${log_file} 2>&1

/usr/bin/docker info | grep -i data

echo " "
echo "thinpool maintenance started at `date`"

# log running containers
/usr/bin/docker ps

# Obtain list of all stopped containers
/usr/bin/docker ps --all | grep 'xited' | cut -f1 -d ' ' > ${thinpool_dir}/${txt_file}
if [ $? -eq 0 ]; then
    echo "step 1 success: list of stopped containers obtained"
else
    echo "step 1 error: obtaining list of stopped containers failed"
    exit
fi

# This starts all stopped containers, they must be running for the
# fstrim command to be able to work
cat ${thinpool_dir}/${txt_file} | xargs /usr/bin/docker start
if [ $? -eq 0 ]; then
    echo "step 2 success: stopped containers started"
else
    echo "step 2 error: starting stopped containers failed"
    exit
fi

# This runs fstrim against all running containers
# if fstrim fails, do we need to exit right away?
# maybe we need to stop the containers that we started.
echo "starting fstrim at `date`"
/usr/bin/docker ps -q | xargs /usr/bin/docker inspect --format='{{ .State.Pid }}' | xargs -IZ fstrim /proc/Z/root/
if [ $? -eq 0 ]; then
    echo "step 3 success: fstrim ran successfully until `date`"
else
    echo "step 3 error: fstrim failed until `date`"
    exit
fi

# This stops all previously stopped containers
cat ${thinpool_dir}/${txt_file} | xargs /usr/bin/docker stop
if [ $? -eq 0 ]; then
    echo "step 4 success: containers stopped successfully"
else
    echo "step 4 error: stopping containers failed"
    exit
fi

#log running conrtainer for cross checking
/usr/bin/docker ps

/usr/bin/docker info | grep -i data
mv ${log_dir}/${log_file} ${log_dir}/${cur_date}_${log_file}
echo "thinpool maintenance ended at `date`"
