#!/bin/bash
# GitHub personal access token with repo scope
# Ensure you have generated a token with appropriate permissions
github_token="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"

# Array of repositories to clone
repos=(
    "https://github.com/amolgire/temp1.git"
    "https://github.com/amolgire/temp2.git"
    # Add more repositories as needed
)

# Directory to clone repositories into
clone_dir="/c/Users/amolg/Temp"

# Function to clone repositories, make changes, and push
clone_repos() {
    for repo in "${repos[@]}"; do
        # Extracting repo name from URL
        repo_name=$(basename "$repo" .git)
        echo "Cloning $repo_name..."
        git clone "$repo" "$clone_dir/$repo_name"
        
        # Change directory to cloned repo
        cd "$clone_dir/$repo_name" || exit
        
        # Create a new branch
        new_branch="feature-CNE-XXXX"
        git checkout -b "$new_branch"
        
        # Make changes to files
        # Example: Editing a file
        sed -i 's/2.5/2.6/g' main.tf
        
        # Add and commit changes
        git add .
        git commit -m "new-feature-CNE-XXXX-Changes via Script"
        
        # Push changes to origin
        git push origin "$new_branch"
        
         # Create pull request using GitHub API
        create_pull_request "$new_branch" "$repo_name"
        
        # Return to the initial directory
        cd -
    done
}
# Function to create pull request using GitHub API
create_pull_request() {
    local branch=$1
    local repo_name=$2
    
    # Get the default branch of the repository
    default_branch=$(git remote show origin | grep 'HEAD branch' | cut -d ':' -f 2 | sed 's/^[[:space:]]*//')
    
    # Create pull request
    response=$(curl -X POST -H "Authorization: token $github_token" -d "{\"title\":\"main << [CNE-1234]-[eversion-update] \", \"head\":\"$branch\", \"base\":\"$default_branch\"}" "https://api.github.com/repos/amolgire/$repo_name/pulls")
    
    # Check if the pull request was successfully created
    if [[ $(echo "$response" | jq -r '.html_url') != "null" ]]; then
        echo "Pull request created for $repo_name"
    else
        echo "Failed to create pull request for $repo_name"
    fi
}

# Call function to clone repos
clone_repos
