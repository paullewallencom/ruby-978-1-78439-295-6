#!/usr/bin/env bash

# Echoes environment variables from a file
# -- ignores comment lines
# -- ignores blank lines
# -- validates format of each line to ensure a proper variable declaration
# -- requires variable names to have a prefix to avoid collisions
# -- skips variables in file if already set, allowing overrides

# safety settings to ensure errors in this script are caught
set -o errexit
set -o pipefail

# set default prefix
: ${CONFIG_PREFIX:='RE09_'}

# if provided, use first argument as path to .env file
if [ ! -z "$1" ]
then
  readonly DOT_ENV_FILE="$1"

# set default path to config file  
else
  # first, safely determine directory where this script is located
  DIR="$(cd "$(dirname "$0")" && pwd)"
  readonly DOT_ENV_FILE="$DIR/.env"
fi

# ensure .env file exists
if [ ! -f "${DOT_ENV_FILE}" ]
then
  echo "File not found: ${DOT_ENV_FILE}" 1>&2;
  exit 1
fi

# only allow alphanumeric and underscore for key names
readonly VALID_KEY_NAME_REGEX='[A-Za-z0-9_]+'

# force all values to be wrapped in single quotes
readonly VALID_VALUE_REGEX="'[^']+'"

readonly LINE_REGEX="^${VALID_KEY_NAME_REGEX}=${VALID_VALUE_REGEX}$"

while read -r line 
do
  # validate basic NAME='VALUE' format
  if [[ ! "$line" =~ ${LINE_REGEX} ]]
  then
    echo "Badly formatted line:"
    echo
    echo "  $line"
    echo
    echo
    echo "* Variable name must include only alphanumeric characters or underscore."
    echo "* Value must be enclosed in single quotes."
    exit 1
  fi

  # validate variable name starts with required prefix
  if [[ ! "$line" =~ ^${CONFIG_PREFIX} ]]
  then
    echo "Variable name does not start with correct prefix:"
    echo
    echo "  $line"
    echo
    echo
    echo "Try:"
    echo
    echo "  ${CONFIG_PREFIX}$line"
    exit 1
  fi
  
  # extracts key name by finding the first '=' character, 
  # via bash parameter expansion:
  # https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html  
  key=${line%%=*} 
  
  # check if variable named $key already defined
  if [ ${!key} ] 
  then
    # env var already set, e.g. to override value in .env file
    # note the warning message is output to STDERR
    echo "skipping $key in file (already set to '${!key}')" 1>&2;
  else
    echo "${line}"
  fi

# remove comments then remove blank lines with grep 
done < <(grep -v '^#' "${DOT_ENV_FILE}" | grep .) 