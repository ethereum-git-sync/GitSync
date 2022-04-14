#!/bin/bash

/usr/bin/git -C ~/repo/github/ethereum clone --mirror git@github.com:$"$1"
/usr/bin/git -C ~/repo/github/$"$1".git push --prune --mirror git@gitee.com:$"$1".git
##rm -rf /home/ubuntu/repo/github/$"$1".git

