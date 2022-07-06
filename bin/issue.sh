#!/bin/bash

echo "/home/ubuntu/repo/github/${1}"
if [ -d /home/ubuntu/repo/github/${1}.git ]
then
	cd /home/ubuntu/repo/github/${1}.git
	gh issue -s all -L 10000 list | awk '{print $1}' >> ~/util/issue/issues.txt 
	FILE="/home/ubuntu/util/issue/issues.txt"
	INPUT=$(cat $FILE)
	for LINE in $INPUT
	do
		touch /home/ubuntu/issue/${1}/"$LINE".json
		gh issue view "$LINE" > /home/ubuntu/issue/${1}/"$LINE".json
		gh issue view -c "$LINE" >> /home/ubuntu/issue/${1}/"$LINE".json
	done
fi

#if [ ! -d /home/ubuntu/issue/${1} ]
#then 
#	mkdir /home/ubuntu/issue/${1}
#fi
