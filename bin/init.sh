#!/bin/bash

#Influx call to indicate sync initialization
curl --request POST "${INFLUX_IP}/api/v2/write?org=git-sync&bucket=gs-monitoring&precision=ns"   --header "Authorization: Token ${INFLUX_API_TOKEN}"   --header "Content-Type: text/plain; charset=utf-8"   --header "Accept: application/json"   --data-binary 'initializations,attempt=0 working=1'

#Main loop 
input="/home/ubuntu/GitSync/util/repo/repolist.txt"
while IFS= read -r line; do
	echo "$line is being sent to sync"
	/bin/bash /home/ubuntu/GitSync/bin/sync.sh "$line"
	echo "$line is being sent to issue"
	/bin/bash /home/ubuntu/GitSync/bin/issue.sh "$line"
done < /home/ubuntu/GitSync/util/repo/repolist.txt
