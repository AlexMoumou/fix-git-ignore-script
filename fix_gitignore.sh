#!/bin/bash
# Ignore files that have already been committed to a git repository

# Store the current directory
current_working_dir=`pwd`

# Assume that the current directory is the git repository
git_repo_path="$current_working_dir"

# Setup output text colors
green_color='\033[0;32m'
red_color='\033[0;31m'
yellow_color='\033[1;33m'
no_color='\033[0m'

# Ask for user confirmation
confirm() {
  # call with a prompt string or use a default
  while true; do
    read -r -p "${1:-Are you sure? [y/N]} " response
    case $response in
      # yes or Yes or YES or y or Y
      [yY]es|YES|[yY]) true; return;;
      # no or No or NO or n or N
      [nN]o|NO|[Nn]) false; return;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Check for wrong parameter number
if (($#>1)); then
    echo "Usage: $0 [git_repo_path]"
    exit 1
fi

# Get the git repository path from the parameter if exists
if (($#==1)); then
  git_repo_path="$1"
fi

# Change current directory to the git repository path
echo -e "===> Git repository: $git_repo_path"
cd "$git_repo_path"

# Check if there are any uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo -e "${yellow_color}===> There are uncommitted changes${no_color}"
  echo -e "${yellow_color}===> You must commit any uncommitted changes because they will be lost${no_color}"
  if ! confirm "Are you sure you want to continue? [y/N]"; then
    # Restore current directory
    cd "$current_working_dir"

    echo -e "${green_color}===> Script ended successful${no_color}"
    exit 0
  fi
fi

# Remove any changed files from the index(staging area)
git rm -r --cached .

# Add back again everything to the index(staging area) [this time taking into account the .gitignore file]
git add .

# Restore current directory
cd "$current_working_dir"

echo -e "${green_color}===> Script ended successful${no_color}"
echo ""
echo "Note: You need to commit and push in order to take place the fix"
