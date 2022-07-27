#!/bin/bash

input="/home/ubuntu/GitSync/repo/repolist.txt"
while IFS= read -r line; do
	/bin/bash /home/ubuntu/GitSync/bin/sync.sh "$line"
	/bin/bash /home/ubuntu/GitSync/bin/issue.sh "$line"
done < /home/ubuntu/GitSync/util/repo/repolist.txt
