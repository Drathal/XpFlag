#!/bin/bash

if [[ $# -eq 0 ]] ; then
    echo 'please add version argument'
    exit 0
fi

branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

versionFile="XpFlag.toc"
versionLabel=$1

devBranch=develop
masterBranch=master
releaseBranch=release/$versionLabel

git checkout -b $releaseBranch $devBranch

sed -i.backup -E "s/\## Version: [0-9.]+/\## Version: $versionLabel/" $versionFile $versionFile
rm $versionFile.backup

git commit -am "Bump version to $versionLabel"

git checkout $masterBranch
git merge --no-ff $releaseBranch

git tag $versionLabel

git checkout $devBranch
git merge --no-ff $releaseBranch

git branch -d $releaseBranch