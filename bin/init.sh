#!/bin/bash

input="/home/ubuntu/util/repo/repolist.txt"
while IFS= read -r line; do
	/bin/bash /home/ubuntu/bin/sync.sh "$line"
#	/bin/bash /home/ubuntu/bin/repo.sh "$line"
done < /home/ubuntu/util/repo/repolist.txt
