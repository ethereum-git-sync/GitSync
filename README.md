# GitSync

This repository contains the codebase for the GitSync project. The intent of the project is to provide a system for automatically mirroring and backing up repositories from one Git hosting service to another. 

The project is currently being hosted via Amazon EC2 instance running Ubuntu 20.04.2 LTS. 

Currently Synced Repos:
```
ethereum/consensus-specs
ethereum/go-ethereum
ethereum/remix-project
ethereum/EIPs
ethereum/PM
ethereum-cat-herders/EIPIP
ethereum-cat-herders/PM
ethereum-git-sync/GitSync
```

Current Hosts:
```
Gitea: https://gitea.com/ethereum-git-sync
       https://gitea.com/tweth
```

## Server Set-up

### SSH Config

Upon accessing the server terminal, verify that an SSH config file exists. 

It can be found at ```~/.ssh/config```. If one does not exist, create one using ```touch ~/.ssh/config```

The contents of the config file should be as shown:
```
Host github.com
	User git
	HostName github.com
	PreferredAuthentications publickey
	IdentitiesOnly yes
	IdentityFile ~/.ssh/SSH_KEY

Host gitea.com
	User git
	HostName gitea.com
        PreferredAuthentications publickey
        IdentitiesOnly yes
	IdentityFile ~/.ssh/SSH_KEY
```
If multiple users for the same host are needed, a Host block can be copied, with only the Host name and IdentityFile needing updated to represent an additional user and their SSH key. Scripts should be updated to reflect this change as well (`git@gitea.com, git@gitea.com-2, etc.`).

SSH_KEY is to be replaced with your own private keys that corrispond to public keys attached to the GitHub/Gitea/etc accounts being used in the syncing scripts. A public key can be added at...

GitHub: https://github.com/settings/keys

Gitea: https://gitea.com/user/settings/keys

### GitHub Credentials

The GitHub CLI is necessary for gaining access to issues in the synced repos, as issues are not a native feature of git.
Installation for Ubuntu (verified using 20.04.2 LTS):
```
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

From there, you must log into a GitHub account with access rights to the synced repos using the command ```gh auth login```. The following shows the necessary inputs in the console for each step. 

```
$ gh auth login
? What account do you want to log into? GitHub.com
? What is your preferred protocol for Git operations? HTTPS
? How would you like to authenticate GitHub CLI? Paste an authentication token
Tip: you can generate a Personal Access Token here https://github.com/settings/tokens
The minimum required scopes are 'repo', 'read:org', 'workflow'.
```

The user is then prompted for a personal access token. The token is necessary for the login process to complete. One must be generated on the GitHub web client at https://github.com/settings/tokens. The necessary permissions are 'repo', 'read:org', and 'workflow'.

### Automation

Script usage is automated via a cronjob. To edit currently running cronjobs, use the command ```crontab -e``` From there, the following job must be added:

```
0 * * * * /usr/bin/bash /home/ubuntu/GitSync/bin/init.sh >> /home/ubuntu/GitSync/log/gitsync.log 2>&1
```

This job will run the main script ```init.sh```, which handles the rest of the scripts. Both standard and error output from the scripts are posted to a log file ```gitsync.log```. This job is set to run hourly; it can and should be edited to match a desired frequency.

### Scripts

```init.sh``` - The main script responsible for executing the other scripts. It is the only one that should be interacted with by the user, either manually or through automation. It is responsible for reading input from a file containing the names of repos that must be maintained, and delegating other scripts to handle repo mirroring and extraction of issue/PR data. 

```sync.sh``` - The script responsible for mirroring repos across multiple git hosting services. It reads in the name of a GitHub repo and distributes the repo to other hosts.

```issue.sh``` - The script responsible for pulling issue data from GitHub for a given synced repo and archiving it. 

## Repository List
```repolist.txt``` contains the list of repos currently being synced. Repos can be submitted for syncing via a pull request containing an edit of this file.
