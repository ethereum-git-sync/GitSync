#!/bin/bash

input="/home/ubuntu/util/repolist.txt"
while IFS= read -r line; do
	/bin/bash /home/ubuntu/bin/sync.sh "$line"
done < /home/ubuntu/util/repolist.txt
