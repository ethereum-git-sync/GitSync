#!/bin/bash

API_LIMIT_REACHED=0
ISSUE_DIRECTORY="/home/ubuntu/github-issues-archive/issue"
#ISSUE_DIRECTORY="/home/ubuntu/GitSync/issue"

function create_directory() {
	echo "$ISSUE_DIRECTORY/$1" 
        if [ ! -d $ISSUE_DIRECTORY/$1 ]
        then
                mkdir -p $ISSUE_DIRECTORY/$1
	fi
}

function clean_up() {
	echo "Cleaning up issues in $1"
        cp $ISSUE_DIRECTORY/$1/issues_current.json $ISSUE_DIRECTORY/$1/issues.json
        rm $ISSUE_DIRECTORY/$1/issues_current.json
        rm $ISSUE_DIRECTORY/$1/index.txt
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
	gh issue -s all -L 100000 --json number,title,author,updatedAt list | jq -r 'sort_by(.updatedAt) | reverse' > $ISSUE_DIRECTORY/${1}/issues_current.json
	echo "The updated list was collected"

	#Generate a text file containing the number of each issue
	jq -r '.[].number' $ISSUE_DIRECTORY/${1}/issues_current.json > $ISSUE_DIRECTORY/${1}/index.txt
	echo "An index was created"

	#Iterate through the text file to compare the time stamps at each issue with those currently archived
        FILE="$ISSUE_DIRECTORY/${1}/index.txt"
        INPUT=$(cat $FILE)
        for LINE in $INPUT
        do
		typeset -i ISSUE_NUMBER=$(echo LINE)
		if [ $API_LIMIT_REACHED == 0 ]
		then
			UPDATED_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' $ISSUE_DIRECTORY/$1/issues_current.json)
			CURRENT_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' $ISSUE_DIRECTORY/$1/issues.json)

			#If the current issue has the same timestamp as its archive, it does not need updated.
			if [ "$UPDATED_TIME" = "$CURRENT_TIME" ]
	       		then
				echo "Issue $ISSUE_NUMBER is up to date"
			#If they are different, then then json file containing the issue must be updated in the archive.
			else
				echo "Issue $ISSUE_NUMBER is not up to date"
				curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER > $ISSUE_DIRECTORY/${1}/"$LINE".json
				curl --silent -H "Authorization: token ${PAT}" https://api.github.com/repos/${1}/issues/$ISSUE_NUMBER/comments \
					>> $ISSUE_DIRECTORY/${1}/"$LINE".json
				gh_api_limit_check "$ISSUE_DIRECTORY/${1}/"$LINE".json"
			fi
		else
			jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" 'del(.[] | select(.number==$ISSUE_NUMBER))' $ISSUE_DIRECTORY/${1}/issues_current.json \
				> $ISSUE_DIRECTORY/${1}/temp.json
			cp $ISSUE_DIRECTORY/${1}/temp.json $ISSUE_DIRECTORY/${1}/issues_current.json
			rm $ISSUE_DIRECTORY/${1}/temp.json
			echo "API LIMIT REACHED @ ISSUE# $LINE"
		fi
        done

	#Remove temporary files and update the local issue list
	clean_up $1
}

if [ -d /home/ubuntu/GitSync/repo/github/${1} ]
then
	create_directory $1
	cd /home/ubuntu/GitSync/repo/github/${1}
	echo ${1}
	gather_issues ${1}
	
	cd $ISSUE_DIRECTORY/
	#git fetch
	#git merge
	#git add .
	#git commit -m "Updated issues for $1"
	#git push
else
	echo "There is no repo to collect issues from."
fi
