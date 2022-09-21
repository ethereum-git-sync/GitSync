#!/bin/bash

API_LIMIT_REACHED=0
BASE_PATH="/home/ubuntu/GitSync/archive"

function create_directory() {
	echo "/home/ubuntu/GitSync/issue/$1" 
        if [ ! -d /home/ubuntu/GitSync/archive/$1/issue ]
        then
                mkdir -p /home/ubuntu/GitSync/archive/$1/issue
	fi

	if [ ! -d /home/ubuntu/GitSync/archive/$1/pr ]
	then
		mkdir -p /home/ubuntu/GitSync/archive/$1/pr
	fi
}

function clean_up() {
	echo "Cleaning up issues in $1"
        cp /home/ubuntu/GitSync/archive/$1/issue/issues_current.json /home/ubuntu/GitSync/archive/$1/issue/issues.json
        rm /home/ubuntu/GitSync/archive/$1/issue/issues_current.json
        rm /home/ubuntu/GitSync/archive/$1/issue/index.txt
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

function gather() {
      	#Generate a JSON file for current issues sorted by most recently updated
        gh issue -s all -L 100000 --json number,title,author,updatedAt list | jq -r 'sort_by(.updatedAt) | reverse' > $BASE_PATH/$1/issue/issues_current.json
        echo "The updated list was collected"

        #Generate a text file containing the number of each issue
        jq -r '.[].number' $BASE_PATH/$1/issue/issues_current.json > $BASE_PATH/$1/issue/index.txt
        echo "An index was created"

        #Iterate through the text file to compare the time stamps at each issue with those currently archived
        FILE="$BASE_PATH/$1/issue/index.txt"
        INPUT=$(cat $FILE)
        for LINE in $INPUT
        do
               	typeset -i ISSUE_NUMBER=$(echo LINE)
               	if [ $API_LIMIT_REACHED == 0 ]
               	then
                       	UPDATED_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' \
                               	$BASE_PATH/$1/issue/issues_current.json)
                       	CURRENT_TIME=$(jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" '.[] | select(.number==$ISSUE_NUMBER) | .updatedAt' \
                               	$BASE_PATH/$1/issue/issues.json)

                       	#If the current issue has the same timestamp as its archive, it does not need updated.
                       	if [ "$UPDATED_TIME" = "$CURRENT_TIME" ]
                       	then
                               	echo "Issue $ISSUE_NUMBER is up to date"
                       	#If they are different, then then json file containing the issue must be updated in the archive.
                       	else
                               	echo "Issue $ISSUE_NUMBER is not up to date"
                               	curl --silent -H "Authorization: token $PAT" https://api.github.com/repos/$1/issues/$ISSUE_NUMBER > $BASE_PATH/$1/issue/"$LINE".json
                               	curl --silent -H "Authorization: token $PAT" https://api.github.com/repos/$1/issues/$ISSUE_NUMBER/comments \
                                       	>> $BASE_PATH/$1/issue/"$LINE".json
                              		gh_api_limit_check "$BASE_PATH/$1/issue/"$LINE".json"
                       	fi
                else
                       	jq -r --argjson ISSUE_NUMBER "$ISSUE_NUMBER" 'del(.[] | select(.number==$ISSUE_NUMBER))' $BASE_PATH/${1}/issue/issues_current.json \
                               	> $BASE_PATH/$1/issue/temp.json
                       	cp $BASE_PATH/$1/issue/temp.json $BASE_PATH/$1/issue/issues_current.json
                       	rm $BASE_PATH/$1/issue/temp.json
                       	echo "API LIMIT REACHED @ ISSUE# $LINE"
               	fi
        done

       	#Remove temporary files and update the local issue list
       	clean_up $1
}

if [ $2 = "issue" ] || [ $2 = "pr" ]
then
	if [ -d /home/ubuntu/GitSync/repo/github/${1} ]
	then
		create_directory $1
		cd /home/ubuntu/GitSync/repo/github/$1
		echo $1
		gather $1 $2

		cd /home/ubuntu/GitSync/archive/
		git fetch
		git merge
		git add .
		git commit -m "Updated issues for $1"
		git push
	else
		echo "There is no repo to collect issues from."
	fi
else
	echo "'issue' or 'pr' must be specified."
fi
