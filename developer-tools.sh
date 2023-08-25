# --- aliases ---
alias ll="ls -la"

# k8s
alias k=kubectl
alias k8s=kubectl
# --- aliases ---

# --- git ---
function clone() {
    PARENT_REGEX="^git@.*:(.*)\/.*.git"

    PARENT=
    if [[ "$1" =~ $PARENT_REGEX ]]
    then
      PARENT="$HOME/git/${match[1]}"
    else
      echo "Invalid git repo url! are you sure you used ssh?"
      return 1
    fi

    FOLDER_REGEX="^git@.*:.*\/(.*).git"

    FOLDER=
    if [[ "$1" =~ $FOLDER_REGEX ]]
    then
      FOLDER="${match[1]}"
    else
      echo "Invalid git repo url! are you sure you used ssh?"
      return 1
    fi

    git clone $1 "$PARENT/$FOLDER"
}

function master() {
    if [ -d "$PWD/.git" ]; then
        git checkout master
        return 0
    fi
    for directory in */; do
        if [ -d "$directory/.git" ]; then
            git -C $directory checkout master
        fi
    done
}

function cleanup_git_branches() {
    if [ -d "$PWD/.git" ]; then
        _cleanup_git_branches $PWD
        return 0
    fi
    for directory in */; do
        if [ -d "$directory/.git" ]; then
            _cleanup_git_branches $directory
        fi
    done
}

function _cleanup_git_branches() {
    REPO=$1
    
    echo "Cleaning up already merged branches in $REPO ..."
    git -C $REPO branch --merged | egrep -v "(^\*|master|dev)" | xargs git -C $REPO branch -D
    
}
# --- git ---

# --- helpers ---
function foreach_file_of_type_in_directory() {
    read "TYPE?Type(default is *): "
    read "DIRECTORY?Directory(default is \$PWD): "
    read "COMMAND?Foreach file: \$FILE -> "
    
    # the .N prevents errors if no matches were found
    for FILE in $(find "${DIRECTORY:-$PWD}" -iname "*.${TYPE:-*}" -maxdepth 1).N; do
        [ -f "$FILE" ] || continue
        eval $COMMAND;
    done
}

# Usage: for_each_folder "$HOME/git" | while read -r; do echo "Working in $REPLY"; cd "$REPLY"; pre-commit install; done
function for_each_folder() {
 for directory in $(find $1 -not -path '*/.*' -mindepth 1 -maxdepth 1 -type d); do
     echo $directory
 done
}

function kill_process_by_port() {
    PORT=$1
    kill $(lsof -t -i:$PORT)
}

function jwt() {
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< $1
}
# --- helpers ---
