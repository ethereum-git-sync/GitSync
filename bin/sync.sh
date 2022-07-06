#!/bin/bash
#----------------------
#repo_owner is used as the repo owner's name on github may not align with the owner's name on other services
repo_owner="${1%%/*}"
repo_name=${1#*/}
#----------------------
if [ ! -d /home/ubuntu/repo/github/$1 ]
then
	echo "Initializing ${1} git repository..."
        /usr/bin/git -C ~/repo/github/$"$repo_owner" clone git@github.com:$"$1"
#	/usr/bin/git -C ~/repo/github/$"$repo_owner" clone --mirror git@github.com:$"$1"
else
	echo "Updating ${1} git repository..."
	/usr/bin/git -C ~/repo/github/$"$1" pull --all 
fi

echo "Copying ${1}..."
if [ "$repo_owner" = "ethereum" ]
then
	/usr/bin/git -C ~/repo/github/$"$1" push --prune --mirror git@gitea.com:ethereum-git-sync/$"$repo_name"
elif [ "$repo_owner" = "ethereum-cat-herders" ]
then
        /usr/bin/git -C ~/repo/github/$"$1" push --prune --mirror git@gitea.com:tweth/$"$repo_name"
fi
#rm -rf /home/ubuntu/repo/github/$"$1".git
#----------------------
