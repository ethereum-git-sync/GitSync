#!/bin/bash

FILE="/home/ubuntu/util/issue_repos.txt"
INPUT=$(cat $FILE)

cd /home/ubuntu/repo/github/ethereum/"$FILE"

for LINE in $INPUT
do
	mkdir /home/ubuntu/archive/issue_archive/ethereum/"$1"/"$LINE"
	gh issue -s all -L 10000 list | awk '{print $1}' >> ~/util/issue_list.txt 
done

