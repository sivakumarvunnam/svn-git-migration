#!/bin/bash
# Maintainer sivakumarvunnam1@gmail.com
migration_jar_path="/home/ubuntu/svn-git-migration"
project_dir="/home/ubuntu/svn-git-migration/"

repo_list=()

if [ $# -eq 0 ]
    then
    echo "No arguments supplied. Reading from $project_dir/repositories.txt file"
    while read repo_name ; do
        repo_list+=($repo_name)
        done < $project_dir/repositories.txt
else
        repo_list=( "$@" )
fi

for repo in "${repo_list[@]}"; do
        echo -e "\n\n\n*****Syncing $repo from SVN to GIT at $(date)*****\n"
        #pushd $(pwd -P)
        pushd "$project_dir/$repo"
        git checkout master
#        git pull origin master
        git svn rebase
        java -Dfile.encoding=utf-8 -jar ${migration_jar_path}/svn-migration-scripts.jar sync-rebase
        java -Dfile.encoding=utf-8 -jar ${migration_jar_path}/svn-migration-scripts.jar clean-git --force
#        git log --oneline origin/master..master
        git push -u origin --all

        if [ "$repo" = "gateways"  ] || [ "$repo" = "expo"  ]; then
                #git reset --hard HEAD~
                #git merge --squash HEAD@{1}
                git commit --amend -m "$repo sync to svn"
                git push -f
        fi

        popd
done
