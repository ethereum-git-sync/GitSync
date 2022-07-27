#!/bin/bash

API_LIMIT_REACHED=0

function create_directory() {
        if [ ! -d /home/ubuntu/GitSync/issue/$1 ]
        then
                mkdir /home/ubuntu/GitSync/issue/$1
        fi
}

function clean_up() {
	echo "Cleaning up issues in $1"
        cp /home/ubuntu/GitSync/issue/$1/issues_current.json /home/ubuntu/GitSync/issue/$1/issues.json
        rm /home/ubuntu/GitSync/issue/$1/issues_current.json
        rm /home/ubuntu/GitSync/issue/$1/index.txt
}

function gh_api_limit_check() {
	echo "Checking file $1..."
	RESULTS=$(jq -r '.message' $1)
	ERROR=$(jq -r '.message' /home/ubuntu/GitSync/util/repo/error_issue.json)
	if [ "$RESULTS" == "$ERROR" ]
	then
		API_LIMIT_REACHED=1
	fi
}

function gather_issues() {
	#Generate a JSON file for current issues sorted by most recently updated
	gh issue -s all -L 100000 --json number,title,author,updatedAt list | jq -r 'sort_by(.updatedAt) | reverse' > /home/ubuntu/GitSync/issue/${1}/issues_current.json
	echo "The updated list was collected"

	#Generate a text file containing the number of each issue
	jq -r '.[].number' /home/ubuntu/GitSync/issue/${1}/issues_current.json > /home/ubuntu/GitSync/issue/${1}/index.txt
	echo "An index was created"

	#Iterate through the text file to compare the time stamps at each issue with those currently archived
        FILE="/home/ubuntu/GitSync/issue/${1}/index.txt"
        INPUT=$(cat $FILE)
        for LINE in $INPUT
        do
		typeset -i ISSUE_NUMBER=$(echo LINE)
		if [ $API_LIMIT_REACHED == 0 ]
		then
			UPDATED_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' /home/ubuntu/GitSync/issue/$1/issues_current.json)
			CURRENT_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' /home/ubuntu/GitSync/issue/$1/issues.json)

			#If the current issue has the same timestamp as its archive, it does not need updated.
			if [ "$UPDATED_TIME" = "$CURRENT_TIME" ]
	       		then
				echo "Issue $ISSUE_NUMBER is up to date"
			#If they are different, then then json file containing the issue must be updated in the archive.
			else
				echo "Issue $ISSUE_NUMBER is not up to date"
				curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER > /home/ubuntu/GitSync/issue/${1}/"$LINE".json
				curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER/comments \
					>> /home/ubuntu/GitSync/issue/${1}/"$LINE".json
				gh_api_limit_check "/home/ubuntu/GitSync/issue/${1}/"$LINE".json"
			fi
		else
			jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" 'del(.[] | select(.number==$ISSUE_NUMBER))' /home/ubuntu/GitSync/issue/${1}/issues_current.json \
				> /home/ubuntu/GitSync/issue/${1}/temp.json
			cp /home/ubuntu/GitSync/issue/${1}/temp.json /home/ubuntu/GitSync/issue/${1}/issues_current.json
			rm /home/ubuntu/GitSync/issue/${1}/temp.json
			echo "API LIMIT REACHED @ ISSUE# $LINE"
		fi
        done

	#Remove temporary files and update the local issue list
	clean_up $1
}

if [ -d /home/ubuntu/GitSync/repo/github/${1} ]
then
	create_directory
	cd /home/ubuntu/GitSync/repo/github/${1}
	echo ${1}
	gather_issues ${1}
	
	cd /home/ubuntu/GitSync
	git fetch
	git merge
	git add /home/ubuntu/GitSync/issue/*
	git commit -m "Updated issues for $1"
	git push
else
	echo "There is no repo to collect issues from."
fi
