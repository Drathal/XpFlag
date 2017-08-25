#!/bin/bash

# current Git branch
branch=$(git symbolic-ref HEAD | sed -e 's,.*/\(.*\),\1,')

# v1.0.0, v1.5.2, etc.
versionLabel=v$1

echo $branch
echo $versionLabel