#!/bin/bash

#repo_owner is used as the repo owner's name on github may not align with the owner's name on other services
repo_owner="${1%%/*}"
repo_name=${1#*/}
account_gitea=""
account_bitbucket=""
account_name_modifier="gs-"
ssh_gitea=""
ssh_bitbucket="bitbucket.org"

if [ ! -d /home/ubuntu/GitSync/repo/github/$1 ]
then
	echo "Initializing ${1} git repository..."
	if [ ! -d /home/ubuntu/GitSync/repo/github/$"$repo_owner" ]
	then
		mkdir -p /home/ubuntu/GitSync/repo/github/$"$repo_owner"
	fi
        /usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$repo_owner" clone git@github.com:$"$1"
else
	echo "Updating ${1} git repository..."
	/usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$1" pull --all
fi

echo "Copying ${1}..."

#Gitea
#The Gitea web client being used has a repo limit of 5 per account, so the repos have to be distributed across multiple accounts temporarily.
if [ "$repo_owner" = "ethereum-cat-herders" ] || [ "$repo_owner" = "ethereum-git-sync" ] || [ "$repo_name" = "solidity" ] || [ "$repo_name" = "DevOps" ] || [ "$repo_owner" = "flashbots" ]
then
        account_gitea="tweth"
        ssh_gitea="gitea.com-tweth"
elif [ "$repo_owner" = "ethereum" ]
then
	account_gitea="ethereum-git-sync"
        ssh_gitea="gitea.com-ethereum-git-sync"
fi

#Bitbucket
account_bitbucket="$account_name_modifier$repo_owner"

#Pushing to all services
echo "Pushing to gitea"
#/usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$1" push --prune --mirror git@$ssh_gitea:$account_gitea/$"$repo_name"
echo "Pushing to bitbucket"
/usr/bin/git -C /home/ubuntu/GitSync/repo/github/$"$1" push --prune --mirror git@$ssh_bitbucket:$account_bitbucket/$"$repo_name"
