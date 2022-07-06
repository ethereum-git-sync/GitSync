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
```

Current Hosts:
```
Gitea: https://gitea.com/ethereum-git-sync
       https://gitea.com/tweth
```

# Server Set-up

# SSH Config

Upon accessing the server terminal, verify that an SSH config file exists. 

It can be found at 

```~/.ssh/config```

If one does not exist, create one

```touch ~/.ssh/config```

The contents of the config file should be as shown...
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
SSH_KEY is to be replaced with your own private keys that corrispond to the public keys attached to the GitHub/Gitea/etc. accounts being used in the syncing scripts. 
