#!/bin/bash

echo "/home/ubuntu/repo/github/${1}"
if [ -d /home/ubuntu/repo/github/${1} ]
then
	if [ ! -d /home/ubuntu/issue/$1 ]
	then
		mkdir /home/ubuntu/issue/$1
	fi

	cd /home/ubuntu/repo/github/${1}
	gh issue -s all -L 100000 list | awk '{print $1}' > ~/issue/${1}/issues.txt
	FILE="/home/ubuntu/issue/${1}/issues.txt"
	INPUT=$(cat $FILE)
	for LINE in $INPUT
	do
		echo $LINE
		touch /home/ubuntu/issue/${1}/"$LINE".json
		curl -H "Authorization: token <PERSONAL_ACCESS_TOKEN>" https://api.github.com/repos/${1}/issues/$LINE > /home/ubuntu/issue/${1}/"$LINE".json
		curl -H "Authorization: token <PERSONAL_ACCESS_TOKEN>" https://api.github.com/repos/${1}/issues/$LINE/comments >> /home/ubuntu/issue/${1}/"$LINE".json
	done
else
	echo "There is no repo to collect issues from."
fi
