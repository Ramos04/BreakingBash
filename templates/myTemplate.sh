#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-o[file]] args ...
#%
#% DESCRIPTION
#%    This is a bash template that is a modified version of the
#%    template created by Michel VONGVILAY (https://www.uxora.com).
#%
#%
#% OPTIONS
#%    -h, --help                    Print this help
#%    -V, --version                 Print script information
#%    -d, --debug                   Print all commands to screen
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -h -v -d
#%
#================================================================
#- IMPLEMENTATION
#-    author          Michel VONGVILAY (https://www.uxora.com)
#-    author          Vincent Ramos (https://github.com/Ramos04)
#-    version         ${SCRIPT_NAME} 0.0.1
#-    license         N/A
#-
#================================================================
#  HISTORY
#     2019/08/13 : Ramos04 : Forked template
#     2019/08/27 : Ramos04 : Absolutely butchered template
#     2019/09/09 : Ramos04 : Cleaned up old template
#     2019/09/17 : Ramos04 : Added functions for printing errors
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

#= DESC: Uses the functions below to give output
#= USE:
#=    output error "Error Message"
#=    output warning "Warning Message"
#=    output success "Success Message"
#=    output other "Other Message"
output(){
    local OUT_TYPE="$1"
    local OUT_MESSAGE="$2"
    case "${OUT_TYPE}" in
        error)    error "$OUT_MESSAGE"
        ;;
        warning ) warning "$OUT_MESSAGE"
        ;;
        success ) success "$OUT_MESSAGE"
        ;;
        other ) other "$OUT_MESSAGE"
        ;;
    esac
}

#= DESC: Log error to stdout and "$LOG_MAIN"
#= PARAM: error message to be printed
error() {
    local ERR_MESSAGE="$1"
    local ERR_TIMESTAMP="$(date)"
    echo ""$ERR_TIMESTAMP" "$SCRIPT_NAME" [ERR]: "$ERR_MESSAGE"" >> "$LOG_MAIN"

    # If verbose flag is enabled
    if [[ "$SCRIPT_VERBOSE" = true ]]; then
        printf "${COL_RED}"$SCRIPT_NAME" [ERR]: "$ERR_MESSAGE"${COL_NORM}\n"
    fi
}

#= DESC: Log warning to stdout and "$LOG_MAIN"
#= PARAM: warning message to be printed
warning() {
    local WARN_MESSAGE="$1"
    local WARN_TIMESTAMP="$(date)"
    echo ""$WARN_TIMESTAMP" "$SCRIPT_NAME" [WAR]: "$WARN_MESSAGE"" >> "$LOG_MAIN"

    # If verbose flag is enabled
    if [[ "$SCRIPT_VERBOSE" = true ]]; then
        printf "${COL_YELLOW}"$SCRIPT_NAME" [WAR]: "$WARN_MESSAGE"${COL_NORM}\n"
    fi
}

#= DESC: Log success to stdout and "$LOG_MAIN"
#= PARAM: success message to be printed
success(){
    local SUC_MESSAGE="$1"
    local SUC_TIMESTAMP="$(date)"
    echo ""$SUC_TIMESTAMP" "$SCRIPT_NAME" [SUC]: "$SUC_MESSAGE"" >> "$LOG_MAIN"

    # If verbose flag is enabled
    if [[ "$SCRIPT_VERBOSE" = true ]]; then
        printf "${COL_GREEN}"$SCRIPT_NAME" [SUC]: "$SUC_MESSAGE"${COL_NORM}\n"
    fi
}

other(){
    local MES_MESSAGE="$1"
    local MES_TIMESTAMP="$(date)"
    echo ""$MES_TIMESTAMP" "$SCRIPT_NAME" [MES]: "$MES_MESSAGE"" >> "$LOG_MAIN"

    # If verbose flag is enabled
    if [[ "$SCRIPT_VERBOSE" = true ]]; then
        printf ""$SCRIPT_NAME" [MES]: "$MES_MESSAGE"\n"
    fi
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
  # |-- flag variables --|
  # +--------------------+
FLAG_VERBOSE=false
FLAG_DEBUG=false

  # +--------------------+
  # |-- date variables --|
  # +--------------------+

readonly DATE_FORMAT="+%Y%m%d"
readonly DATE_SCRIPT_EXEC=$(date ${DATE_FORMAT})
readonly DATE_LOG_TIMESTAMP="$(date)"

  # +--------------------+
  # |-- file variables --|
  # +--------------------+

readonly LOG_MAIN="$(pwd)/output.log"
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
readonly COL_BLACK=$'\e[0;30m'
readonly COL_RED=$'\e[0;31m'
readonly COL_GREEN=$'\e[0;32m'
readonly COL_YELLOW=$'\e[0;33m'
readonly COL_BLUE=$'\e[0;34m'
readonly COL_PURPLE=$'\e[0;35m'
readonly COL_CYAN=$'\e[0;36m'

readonly COL_BOLD_BLACK=$'\e[1;30m'
readonly COL_BOLD_RED=$'\e[1;31m'
readonly COL_BOLD_GREEN=$'\e[1;32m'
readonly COL_BOLD_YELLOW=$'\e[1;33m'
readonly COL_BOLD_BLUE=$'\e[1;34m'
readonly COL_BOLD_PURPLE=$'\e[1;35m'
readonly COL_BOLD_CYAN=$'\e[1;36m'

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
OPT_ERR=0

#= Change to reflect the number of options the program has
OPT_TOTAL=0

#= Options for the flags
OPT_OPTS=":hV-:"

while getopts "$OPT_OPTS" OPTION; do
    case "${OPTION}" in
        -)
            case "${OPTARG}" in
                help )     usagefull; exit 0;
                ;;
                version )  scriptinfo "ver"; exit 0;
                ;;
                verbose )  FLAG_VERBOSE=true;
                ;;
                debug )  FLAG_DEBUG=true;
                ;;
                *)  error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
                    OPT_ERR=1
                ;;
            esac
        ;;
        h ) usagefull; exit 0;
        ;;
        V ) scriptinfo "ver"; exit 0;
        ;;
        v )  FLAG_VERBOSE=true;
        ;;
        d )  FLAG_DEBUG=true;
        ;;
        : ) echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            OPT_ERR=1; exit 1;
        ;;
        ? ) echo "${SCRIPT_NAME}: -$OPTARG: unknown option"
            OPT_ERR=1; exit 1;
        ;;
        *)  echo "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
            OPT_ERR=1; exit 1;
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

#= DESC: Checks for debug flag
if [[ "$FLAG_DEBUG" = true ]] && set -x

  #================#
  #====  main  ====#
  #================#



  #================#
  #====  end   ====#
  #================#


  #================#
  #====  post  ====#
  #================#
