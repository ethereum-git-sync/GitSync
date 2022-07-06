#!/bin/bash

FILE="/home/ubuntu/util/issue_list.txt"
INPUT=$(cat $FILE)

cd /home/ubuntu/repo/github/ethereum/"$1".git
for LINE in $INPUT
do
	touch /home/ubuntu/git/issue_archive/ethereum/"$1"/"$LINE".json
	gh issue view "$LINE" > /home/ubuntu/git/issue_archive/ethereum/"$1"/"$LINE".json
	gh issue view -c "$LINE" >> /home/ubuntu/git/issue_archive/ethereum/"$1"/"$LINE".json
done
