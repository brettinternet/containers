#!/bin/bash

function run_commands {
  COMMANDS=$1
  while IFS= read -r cmd; do echo "$cmd" && eval "$cmd" ; done < <(printf '%s\n' "$COMMANDS")
}

function run_exit_commands {
  set +e
  set +o pipefail
  run_commands "${POST_COMMANDS_EXIT:-}"
}

function update {
  WORKING_DIRECTORY="${WORKING_DIRECTORY:-"/repos"}"
  WORKING_DIRECTORY=$(echo "$WORKING_DIRECTORY" | sed 's:/*$::')
  REMOTE="$1"
  BASENAME=$(basename $REMOTE)
  REPO_NAME="${BASENAME%.*}"
  REPO_OWNER=$(echo $REMOTE | awk -F "/" '{print $4}')
  REPO_PARENT_DIR="$WORKING_DIRECTORY/$REPO_OWNER"
  REPO_PATH="$REPO_PARENT_DIR/$REPO_NAME"

  if [ -d "$REPO_PATH" ]; then
    echo "Updating mirror in $REPO_PATH"
    git -C $REPO_PATH remote update -p
  else
    mkdir -p $REPO_PARENT_DIR
    echo "Cloning mirror $REMOTE to $REPO_PATH"
    git -C $REPO_PARENT_DIR clone --mirror $REMOTE $REPO_NAME
  fi
}

function run {
  DELIMITTED_REMOTES=(${GIT_REMOTES//,/ })
  PREFIX="GIT_REMOTE_"
  PREFIXED_REMOTE_VARS=($(env | awk -F "=" '{print $1}' | grep "^$PREFIX"))
  PREFIXED_REMOTES=()
  for VARIABLE in "${PREFIXED_REMOTE_VARS[@]}"; do
    if [[ -n "${!VARIABLE}" ]]; then
      PREFIXED_REMOTES+=("${!VARIABLE}")
    fi
  done
  REMOTES=("${DELIMITTED_REMOTES[@]}" "${PREFIXED_REMOTES[@]}")
  for REMOTE in "${REMOTES[@]}"; do
    if [[ -n "${REMOTE}" ]]; then
      update "${REMOTE}"
    fi
  done
}

trap run_exit_commands EXIT

run_commands "${PRE_COMMANDS:-}"

start=$(date +%s)
echo Starting updates at $(date +"%Y-%m-%d %H:%M:%S")

set +e
run
RC=$?
set -e

if [ $RC -ne 0 ]; then
  if [ $RC -eq 3 ] && [ -n "${POST_COMMANDS_INCOMPLETE:-}" ]; then
      run_commands "${POST_COMMANDS_INCOMPLETE:-}"
  else
      run_commands "${POST_COMMANDS_FAILURE:-}"
  fi
fi

echo Updates successful

end=$(date +%s)
echo Finished updates at $(date +"%Y-%m-%d %H:%M:%S") after $((end-start)) seconds

[ $RC -ne 0 ] && exit $RC

run_commands "${POST_COMMANDS_SUCCESS:-}"
