#!/bin/bash

echo "========================================="
echo "Setting up GIT environment"
echo "========================================="

alias git-list-remote-branch='git fetch && git branch -r'
alias git-list-remote-branch-verbose='git remote show origin'
alias git-logs-summarized-from-all-branches='git branch -avv'
alias git-logs-summarized-from-local-branches='git branch -lvv'
alias git-logs-short='git log --pretty=oneline --decorate --abbrev-commit HEAD~3..HEAD'
alias git-logs-graph='git log --graph --pretty=oneline --decorate'
alias git-logs-graph-author='git log --graph --pretty=format:"%H%x09%an%x09%ad%x09%s" --decorate'
alias git-whats-stashed='git stash show -p'
alias git-refresh-remote-branch='git remote update origin --prune'
alias git-undo-previous-commit='git reset --soft HEAD^1'


function git_log() {
	git log --pretty=oneline --decorate --graph $1
}

function git_logs_only_branch() {
	if [[ $1 == ""  ]]; then
                echo "Only log from specific branch"
                echo "1st param: branch name"
        else
		# https://marcgg.com/blog/2015/08/04/git-first-parent-log/
                git log --first-parent $1
        fi
}


function git_diff_merge() {
	if [[ $1 == "" || $2 == "" ]]; then
		echo "Showing a diff on a merge."
		echo "To use this, do a git-logs-only-branch on the branch first, then search for the SHA of the merge"
		echo "1st param: branch name"
		echo "2nd param: SHA of the merge"
	else
		merges=`git log --first-parent $1 | grep -A 2 $2 | grep Merge`
		echo "Merges are $merges"
		sha1=$(echo $merges | sed -e 's/Merge: \(.*\) \(.*\)/\1/g')
		echo "Sha1 is $sha1"
		sha2=$(echo $merges | sed -e 's/Merge: \(.*\) \(.*\)/\2/g')
		echo "Sha2 is $sha2"
		git diff $sha2..$sha1
	fi
}

function git_logs_from_all_branch_detailed(){
	git log -p -all
}

function parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

## Find all branches that have been merged to current branch
function git_create_patch_from_stash() {
	if [[ $1 == "" || $2 == "" ]]; then
		echo "Creating patch from stash"
		echo "1st param: stash name"
		echo "2nd param: export (output file) name"
	else		
		git stash show -p $1 > $2
	fi
}

function git_tag_show_creation_date(){
        if [[ $1 == ""  ]]; then
                echo "Show tag creation date"
                echo "1st param: tag name"
        else
                git log -1 --format=%ai $1
        fi

}


function git_branch_rename(){
	if [[ $1 == "" || $2 == "" ]]; then
		echo "Rename LOCAL branch"
		echo "1st param: old name"
		echo "2nd param: new name"
	else		
		echo "Renaming $1 to $2. This is only done LOCALLY"
		git branch -m $1 $2
	fi

}

function git_branch_rename_tracked(){
	if [[ $1 == "" || $2 == "" ]]; then
		echo "Rename TRACKED branch"
		echo "1st param: old name"
		echo "2nd param: new name"
	else		
		echo "Renaming $1 to $2 locally."
		git branch -m $1 $2
		echo "Deleting remote $1."
		git-branch-delete-remote $1
		echo "Pushing $2 to remote."
		git push -u origin $2:$2
	fi


}


function git_branch_delete_remote() {
	if [[ $1 == "" ]]; then
		echo "Deleting remote branch"
		echo "1st param: branch name"
	else		
		git push origin --delete $1
	fi

}

function git_checkout_branch_from_upstream() {
	if [[ $1 == "" ]]; then
		echo "Checking out branch from upstream and push to origin"
		echo "1st param: branch name in upstream"
	else
		git checkout -b $1 -t upstream/$1
		git push -u origin $1
	fi
}


function git_branches_find_merged() {
	echo "The following branches HAS BEEN merged to current branch \"$(parse_git_branch)\"."
	git fetch && git branch --merged
}


function git_branches_find_unmerged(){
	if [[ $1 == "" ]]; then
		echo "Finding all branches that HAS NOT been merged into a given branch"
		echo "Param: destination branch name"
	else	
		git fetch && git branch --no-merged $1
	fi
}

# function git-branches-find-merged-destination(){
# 	if [[ $1 == "" ]]; then
# 		echo "Finding all branches that HAS merged a given branch"
# 		echo "Param: branch name"
# 	else	
# 		git fetch && git branch --merged $1
# 	fi
# }
# 

function git_branches_containing(){
	if [[ $1 == "" ]]; then
		echo "Finding branches that contains SHA/branch: $1"
		echo "Param: SHA"
	else	
		git fetch && git branch --contains $1
	fi	
}

function git_create_patch_from_commit(){
	if [[ $1 == "" ]]; then
		echo "Creating patch from a SHA"
		echo "Param: SHA"
	else		
		git format-patch -1 $1
	fi
}

function git_check_patch(){
	echo "Checking patch : $1"
	git apply --stat $1
	git apply --check $1
}

function git_make_local_same_as_remote(){
	if [[ $1 == "" ]]; then
		echo "Make local branch to be the same as remote branch"
		echo "Param: branch name"
	else
		git fetch origin
		git reset --hard origin/$1
	fi
}

function git_prune_merged_branches(){
	git checkout master
	git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d
}

#function git-find-unmerged-old {
#	echo "You are asking me which commits have not been merged from $1 to current branch \"$(parse_git_branch)\""
#	git log $1 ^$(parse_git_branch) --no-merges
#}

function git_commits_find_unmerged() {
	if [[ $1 == "" ]]; then
		echo "Find commits that have not been merged from current branch to destination branch"
		echo "Param:  destination branch"
	else		
		echo "You are asking me which commits have not been merged from current branch \"$(parse_git_branch)\" to $1"
		git cherry -v $1
	fi
}

function git_commits_find_unmerged_detailed() {
	if [[ $1 == "" ]]; then
		echo "Find detailed commits that has not been merged to destination branch"
		echo "Param: destination branch"
	else
		git log --no-merges --stat --reverse $1..
	fi
}

function git_commits_find_unmerged_verbose() {
	if [[ $1 == "" || $2 == "" ]]; then
		echo "Find commits that have not been merged from source branch to destination branch"
		echo "1st param:  source branch"
		echo "2nd param:  destination branch"
	else		
		echo "You are asking me which commits have not been merged from $1 to $2"
		git cherry -v $2 $1
	fi
}


function git_commits_find_incoming() {
	if [[ $1 == "" ]]; then
		echo "Find commits from branch $1 that will be merge to current branch"
		echo "Param: source branch"
	else
		echo "You are asking me what commits from $1 are missing in the current branch \"$(parse_git_branch)\""
		git cherry -v $(parse_git_branch) $1
	fi
}

function git_commit_pick_specific(){
	if [[ $1 == "" ]]; then
		echo "Merging commit with a given SHA to the current branch"
		echo "Param: SHA"
	else
		git cherry-pick $1
	fi
}

function git_checkout_remote_branch {
	if [[ $1 == "" ]]; then
		echo "Param: remote branch name"
		echo "List of remote branches:"
		git-list-remote-branch
	else
		echo "You are asking me to checkout remote branch $1 into local branch $1"
		git fetch

		## checkout origin branch with the given name as local branch, and switch to it
		git checkout -b $1 -t origin/$1
	fi
}

function parse_git_branch {
    git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function git_what_will_be_pushed() {
	git diff --stat origin/$(parse_git_branch)..HEAD
}

function git_what_will_be_pushed_verbose() {
	git diff origin/$(parse_git_branch)..HEAD
}

function git_diff_file_in_two_branches() {
	if [[ $1 == "" || $2 == "" || $3 == "" ]]; then
		echo "1st Param: file path"
		echo "2nd Param: branch 1"
		echo "3rd Param: branch 2"
	else
		echo "You are asking me to compare file $1 between branch $2 and branch $3"
		git diff $2 $3 -- $1
	fi
}

function git_undo_merge(){
	if [[ $1 == "" ]]; then
		echo "Param: SHA"
	else
		echo "You are asking me to revert a merge commit with hash $1"
		git revert -m 1 $1
	fi
}

function git_merge_squashed(){
	echo "Merging branch $1 squashed into current branch"
	git merge --squash $1
}

function git_change_tracking(){
	echo "You are asking me to change branch $1 to be tracking from remote $2"
	git branch --set-upstream $1 $2
}

function git_push_origin(){
	echo "Pushing current branch to origin $(parse_git_branch)"
	git push -u origin $(parse_git_branch)
}


function git_push_other_branch_to_origin(){
	if [[ $1 == "" || $2 == "" ]]; then
		echo "1st Param: local branch name"
		echo "2nd Param: remote branch name"
	else
		echo "Pushing local branch: $1  to track remote branch: $2"
		git push -u origin $1:$2
	fi
}

function git_show_file_at(){
	echo "Showing content of $1 at $2"
	git show "$2":"$1"
}

function git_make_script_executable(){
	if [[ $1 == "" ]]; then
		echo "Param: filename"
	else
		git update-index --chmod=+x $1
	fi
}

function git_update_other_branch(){
	if [[ $1 == "" ]]; then
		echo "Param: branch name"
	else
		echo "Updating branch $1"
		git fetch origin $1:$1
	fi
}
