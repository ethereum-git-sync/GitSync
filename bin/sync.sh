#!/bin/bash

#repo_owner is used as the repo owner's name on github may not align with the owner's name on other services
repo_owner="${1%%/*}"
repo_name=${1#*/}

if [ ! -d /home/ubuntu/GitSync/repo/github/$1 ]
then
	echo "Initializing ${1} git repository..."
	if [ ! -d /home/ubuntu/GitSync/repo/github/$"$repo_owner" ]
	then
		mkdir /home/ubuntu/GitSync/repo/github/$"$repo_owner"
	fi
        /usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$repo_owner" clone git@github.com:$"$1"
else
	echo "Updating ${1} git repository..."
	/usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$1" pull --all 
fi

echo "Copying ${1}..."
gitea_account=""
if [ "$repo_owner" = "ethereum" ]
then
	gitea_account="ethereum-git-sync"
	gitea_ssh="gitea.com-ethereum-git-sync"
elif [ "$repo_owner" = "ethereum-cat-herders" ] || [ "$repo_owner" = "ethereum-git-sync" ] 
then
	gitea_account="tweth"
	gitea_ssh="gitea.com-tweth"
fi

/usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$1" push --prune --mirror git@${gitea_ssh}:$gitea_account/$"$repo_name"
