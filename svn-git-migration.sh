#!/bin/bash
# Maintainer sivakumarvunnam1@gmail.com
authors_file="/home/ubuntu/svn-git-migration/authors.txt"
svn_project_loc="https://192.168.20.190/svn"
#svn_project_loc="https://192.168.20.190/svn/expo"
#git_project_loc="ssh://git@git.XXXXXXXXXX.com:7999/EXPO"
git_project_loc="ssh://git@git.XXXXXXXXXX.com:7999/mk"
svn_migration_jar_loc="/home/ubuntu/svn-git-migration/svn-migration-scripts.jar"
project_dir="/home/ubuntu/svn-git-migration"

repo_list=()

if [ $# -eq 0 ]
    then
    echo "No arguments supplied. Reading from migration_repo_list.txt file"
    while read repo_name ; do
        repo_list+=($repo_name)
        done < migration_repo_list.txt
else
        repo_list=( "$@" )
fi

for repo in "${repo_list[@]}"; do
        non_std_layout_opt=""
        repo_cleanup=false
        non_std_dir_count=$(svn ls $svn_project_loc/$repo       | grep -aEi 'trunk|tags|branch' | wc -l)
        if [ $non_std_dir_count -gt 0 ] ; then
                non_std_layout_opt="-s"
                repo_cleanup=true
        fi

        echo "Cloning SVN repo $repo to local using git svn"
        git svn clone --username=svunnam --authors-file="$authors_file" --prefix "" $non_std_layout_opt "$svn_project_loc/$repo" $repo
        git svn fetch
        git svn rebase
        pushd "$project_dir/$repo"

        if [ $repo_cleanup = true ] ; then
                java -Dfile.encoding=utf-8 -jar $svn_migration_jar_loc clean-git
                java -Dfile.encoding=utf-8 -jar $svn_migration_jar_loc clean-git --force
        fi

        git remote add origin "$git_project_loc/$repo"
        git push -u origin --all
        popd

done
