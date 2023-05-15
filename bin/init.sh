#!/bin/bash

input="/home/ubuntu/GitSync/util/repo/repolist.txt"
while IFS= read -r line; do
	echo "$line is being sent to sync"
	/bin/bash /home/ubuntu/GitSync/bin/sync.sh "$line"
#	echo "$line is being sent to issue"
#	/bin/bash /home/ubuntu/GitSync/bin/issue.sh "$line"
done < /home/ubuntu/GitSync/util/repo/repolist.txt
