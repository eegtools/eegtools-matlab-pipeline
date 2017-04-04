git filter-branch --commit-filter '
    if [ "$GIT_AUTHOR_NAME" = "inuggi" -o "$GIT_AUTHOR_NAME" = "campus" -o "$GIT_AUTHOR_NAME" = "albaspazio" ];
    then
            git commit-tree "$@";
    else
            skip_commit "$@";
    fi' HEAD

git push origin +master:master



# add untracked

git add -A
git commit -a -m "My commit message"
