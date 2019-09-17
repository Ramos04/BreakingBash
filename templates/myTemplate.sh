#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-o[file]] args ...
#%
#% DESCRIPTION
#%    This a template for bash scripts
#%
#% OPTIONS
#%    -h, --help                    Print this help
#%    -V, --version                 Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -h -v
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} 0.0.1
#-    author          Vincent Ramos (https://github.com/Ramos04)
#-    license         N/A
#-
#================================================================
#  HISTORY
#     2019/08/13 : Ramos04 : Created Template
# 
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================

  # +---------------------+
  # |-- Script Breakers --|
  # +---------------------+
#= DESC: Causes script to fail on unset variables, pipe errors, non 0 exit code
set -euo pipefail

#= Make bash arrays easier to work with
IFS=$'\n\t'

#============================
#  FUNCTIONS
#============================

  # +----------------------+
  # |-- custom functions --|
  # +----------------------+

#= DESC: Checks if script is run as root
#= EXIT: if EUID is not root
sudocheck() {
    # Check if script is run as root
    if [ "$EUID" -ne 0 ]
        then echo "Please run as root"
        exit
    fi
}

 # All user defined functions should be placed here

  # +----------------------------------+
  # |-- startup and finish functions --|
  # +----------------------------------+

#= DESC: Cleanup temp files on exit
cleanup() {
    # Check if there are temp files, if so clean up
    if [[ ${#TEMP_FILES[@]} > 0 ]]; then
        rm -f "${TEMP_FILES[@]}"
    fi
}

trap cleanup EXIT

  # +-----------------------+
  # |-- logging functions --|
  # +-----------------------+

#= DESC: Log error to stdout and "$LOG_MAIN"
#= PARAM: error message to be printed
error() {
    local ERR_MESSAGE="$1"
    local ERR_TIMESTAMP="$(date)"
    echo ""$ERR_TIMESTAMP" "$SCRIPT_NAME" [ERR]: "$ERR_MESSAGE"" 2>&1 \
        | tee -a "$LOG_MAIN"
}

#= DESC: Log warning to stdout and "$LOG_MAIN"
#= PARAM: warning message to be printed
warning() {
    local WARN_MESSAGE="$1"
    local WARN_TIMESTAMP="$(date)"
    echo ""$WARN_TIMESTAMP" "$SCRIPT_NAME" [WARN]: "$WARN_MESSAGE"" 2>&1 \
    | tee -a "$LOG_MAIN"
}

#= DESC: Log success to stdout and "$LOG_MAIN"
#= PARAM: success message to be printed
success(){
    local SUC_MESSAGE="$1"
    local SUC_TIMESTAMP="$(date)"
    echo ""$SUC_TIMESTAMP" "$SCRIPT_NAME" [SUC]: "$SUC_MESSAGE"" 2>&1 \
    | tee -a "$LOG_MAIN"
}

  # +---------------------+
  # |-- usage functions --|
  # +---------------------+

#= DESC: Displays usage information
usage() {
    printf "Usage: ";
    scriptinfo usg ;
}

#= DESC: Displays full usage information
usagefull() {
    scriptinfo ful;
}

#= DESC: Displays script information
scriptinfo() { headFilter="^#-";
    if [[ ! -z "$1" ]];then
        [[ "$1" = "usg" ]] && headFilter="^#+"
        [[ "$1" = "ful" ]] && headFilter="^#[%+]"
        [[ "$1" = "ver" ]] && headFilter="^#-"
    fi
    head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | \
        sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g";
}

#============================
#  FILES AND VARIABLES
#============================

  # +-----------------------+
  # |-- general variables --|
  # +-----------------------+

readonly SCRIPT_VERSION="0.0.1"
readonly SCRIPT_NAME_EXT="$(basename ${0})"              # scriptname without path
readonly SCRIPT_NAME="${SCRIPT_NAME_EXT%.*}"             # scriptname without .sh
readonly SCRIPT_DIR="$( cd $(dirname "$0") && pwd )"     # Script Directory
readonly SCRIPT_ROOT="${SCRIPT_DIR%/*}"	                # Add a /* depending on script depth
readonly SCRIPT_FULLPATH="${SCRIPT_DIR}/${SCRIPT_NAME}"  # Full path of the script
readonly SCRIPT_HOSTNAME="$(hostname)"                   # Hostname
readonly SCRIPT_COMMAND_FULL="${0} $*"                   # Full command
readonly SCRIPT_EXEC_ID=${$}                             # Exec ID
readonly SCRIPT_HEADSIZE=$(grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d:)

  # +--------------------+
  # |-- date variables --|
  # +--------------------+

readonly DATE_FORMAT="+%Y%m%d"
readonly DATE_SCRIPT_EXEC=$(date ${DATE_FORMAT})
readonly DATE_LOG_TIMESTAMP="$(date)"

  # +--------------------+
  # |-- file variables --|
  # +--------------------+

readonly LOG_MAIN="$(pwd)/"$SCRIPT_NAME".log"
readonly LOG_ERR="$(pwd)/error.log"

  # +----------------+
  # |-- temp files --|
  # +----------------+

TEMP_FILES=()                                # Need to add all temp dir/file paths
                                             # to this. Exit trap uses this to
                                             # clean on scrip exit
readonly TEMP_DIR=$SCRIPT_DIR"/tmp"          # Change this to TEMP_FILE_<name>
                                             # for as manytemp dirs are needed
readonly TEMP_FILE=$SCRIPT_DIR"/<name>.tmp"  # Change this to TEMP_FILE_<name>
                                             # for as many temp files are needed

  # +------------------+
  # |-- color output --|
  # +------------------+

readonly COL_NORM=$'\e[0m'
readonly COL_RED=$'\e[0;31m'
readonly COL_GREEN=$'\e[0;32m'
readonly COL_BLUE=$'\e[0;34m'
readonly COL_BLACK=$'\e[0;30m'
readonly COL_BOLD_RED=$'\e[1;31m'
readonly COL_BOLD_GREEN=$'\e[1;32m'
readonly COL_BOLD_BLUE=$'\e[1;34m'
readonly COL_BOLD_BLACK=$'\e[1;30m'

  # +------------------------+
  # |-- function variables --|
  # +------------------------+
# Define variables that will be used in funcitons

#============================
#  PARSE OPTIONS WITH GETOPTS
#============================

  # +----------------------+
  # |-- option variables --|
  # +----------------------+

#= Gets set when an error occurs parsing flags
FLAG_OPT_ERR=0

#= Change to reflect the number of options the program has
FLAG_OPT_TOTAL=0

#= Options for the flags
FLAG_OPTS=":hV-:"

while getopts "$FLAG_OPTS" OPTION; do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                help )     usagefull; exit 0;
                ;;
                version )  scriptinfo "ver"; exit 0;
                ;;
                *)  error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
                    FLAG_OPT_ERR=1
                ;;
            esac
        ;;
        h ) usagefull; exit 0;
        ;;
        V ) scriptinfo "ver"; exit 0;
        ;;
        : ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            FLAG_OPT_ERR=1; exit 1;
        ;;
        ? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option"
            FLAG_OPT_ERR=1; exit 1;
        ;;
        *)  echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            FLAG_OPT_ERR=1; exit 1;
        ;;
    esac
done
shift $((${OPTIND} - 1)) ## shift options

#============================
#  MAIN SCRIPT
#============================

  #================#
  #== pre-script ==#
  #================#

#= DESC: Check $FLAG_OPT_ERR for argument erros
#= EXIT: On $FLAG_OPT_ERR flag being set
[[ $FLAG_OPT_ERR -eq 1 ]] && usage 1>&2 && exit 1

#= DESC: Checks for correct number of arguments
#= EXIT: On too many arguments being passed in
[[ $# -gt "$FLAG_OPT_TOTAL" ]] && echo "${SCRIPT_NAME}: Too many arguments" && \
    usage 1>&2 && exit 2

  #================#
  #====  main  ====#
  #================#

  #================#
  #====  end   ====#
  #================#

  #================#
  #====  post  ====#
  #================#
