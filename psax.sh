#!/bin/bash
hz=$(getconf CLK_TCK)
proc=$(ls /proc/ | grep [0-9] | sort -g)
for process in $proc
do
path="/proc/$process"
if [[ $(cat $path/cmdline 2>/dev/null | wc -c) -eq 0 ]]
	then
	cmd=$(cat $path/stat 2>/dev/null | awk '{print $2}')
	else
        cmd=$(cat $path/cmdline 2>/dev/null)
fi
if [[ $(ls -l $path/fd 2>/dev/null | grep -E 'tty|pts' | wc -c) -eq 0 ]]
	then
	tty='?'
	else
	tty=$(ls -l $path/fd 2>/dev/null | grep -E 'tty|pts' | head -1 | cut -d\/ -f3,4)
fi
state=$(cat $path/stat 2>/dev/null | awk '{print $3}')
ut=$(cat $path/stat 2>/dev/null | awk '{print $14}')
st=$(cat $path/stat 2>/dev/null | awk '{print $15}')
cut=$(cat $path/stat 2>/dev/null | awk '{print $16}')
cst=$(cat $path/stat 2>/dev/null | awk '{print $17}')
total=$((ut+st+cut+cst))
total_sec=$((total/hz))
proc_time=$(date -d@$total_sec -u +%H:%M:%S)
printf "%-5s  %-1s  %-10s  %-5s %s\n" $process $state $proc_time $tty $cmd
done

