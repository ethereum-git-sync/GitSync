#!/bin/bash

input="/home/ubuntu/util/repo/repolist.txt"
while IFS= read -r line; do
	/bin/bash /home/ubuntu/bin/sync.sh "$line"
done < /home/ubuntu/util/repo/repolist.txt

#input="/home/ubuntu/util/repo/repos_ethereum-cat-herders.txt"
