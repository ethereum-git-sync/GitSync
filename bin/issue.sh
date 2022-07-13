#!/bin/bash

function force_quit() {
	echo "Error: $1"
	exit
}

function create_directory() {
        if [ ! -d /home/ubuntu/issue/$1 ]
        then
	 	mkdir /home/ubuntu/issue/$1
        fi
}

function gather_issues() {
	#Generate a JSON file for current issues sorted by most recently updated
	gh issue -s all -L 100000 --json number,title,author,updatedAt list | jq -r 'sort_by(.updatedAt) | reverse' > ~/issue/${1}/issues_current.json
	
	#Generate a text file containing the number of each issue
	jq -r '.[].number' ~/issue/${1}/issues_current.json > ~/issue/${1}/index.txt
	
	#Iterate through the text file to compare the time stamps at each issue with those currently archived
        FILE="/home/ubuntu/issue/${1}/index.txt"
        INPUT=$(cat $FILE)
        for LINE in $INPUT
        do
		typeset -i ISSUE_NUMBER=$(echo LINE)
		UPDATED_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' ~/issue/$1/issues_current.json)
		CURRENT_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' ~/issue/$1/issues.json)

		#If the current issue has the same timestamp as its archive, we can assume all following issues are up-to-date and leave the loop
		if [ "$UPDATED_TIME" = "$CURRENT_TIME" ]
	       	then
			break
		#If they are different, then then json file containing the issue must be updated in the archive.
		else
			curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER > /home/ubuntu/issue/${1}/"$LINE".json
			curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER/comments \
				>> /home/ubuntu/issue/${1}/"$LINE".json
		fi
        done

	#Clean-up
	cp ~/issue/$1/issues_current.json ~/issue/$1/issues.json
	rm ~/issue/$1/issues_current.json
	rm ~/issue/$1/index.txt
}

if [ -d /home/ubuntu/repo/github/${1} ]
then
	create_directory
	cd /home/ubuntu/repo/github/${1}
	echo ${1}
	gather_issues ${1}
else
	echo "There is no repo to collect issues from."
fi
