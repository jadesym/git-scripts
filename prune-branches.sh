#!/bin/bash

# Ensure we're in a Git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "This is not a Git repository."
  exit 1
fi

# Check for unstaged changes
if ! git diff --quiet; then
    echo "There are unstaged changes. Please commit or stash them before running this script."
    exit 1
fi

# Fetch updates from the remote repository and prune any deleted remote branches
git fetch origin --prune

# Checkout to the 'main' branch
git checkout main

# Pull the latest updates from the 'main' branch
git pull origin main

# List all local branches
for branch in $(git branch --format "%(refname:short)"); do
  # Skip if we're already on the 'main' branch
  if [ "$branch" == "main" ]; then
    continue
  fi

  # Checkout the branch
  git checkout "$branch"

  # Rebase the branch against origin/main
  git rebase origin/main

  # If there are conflicts, abort the rebase and print a message
  if [ $? -ne 0 ]; then
    echo "Rebase of $branch has conflicts. Aborting rebase."
    git rebase --abort
    continue
  fi

  # Check if there are any differences between the branch and main
  if [ -z "$(git diff origin/main..HEAD)" ]; then
    # If there are no differences, delete the branch
    echo "No differences between $branch and main. Deleting $branch."
    git checkout main
    git branch -d "$branch"
  fi
done

# Go back to the main branch when done
git checkout main

