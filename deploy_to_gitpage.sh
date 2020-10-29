#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo --cleanDestinationDir # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public
# Add changes to git.
git add .

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push

# Come Back up to the Project Root
cd ..

# push updates of the project to repository "blog"
git add .
git add --all #sometimes works in linux
git commit -m "update blog"
git push
