#!/bin/bash
#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-hv] [-o[file]] args ...
#%
#% DESCRIPTION
#%    This is a script template
#%    to start any good shell script.
#%
#% OPTIONS
#%    -o [file], --output=[file]    Set log file (default=/dev/null)
#%                                  use DEFAULT keyword to autoname file
#%                                  The default value is /dev/null.
#%    -h, --help                    Print this help
#%    -v, --version                 Print script information
#%
#% EXAMPLES
#%    ${SCRIPT_NAME} -o DEFAULT arg1 arg2
#%
#================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} ${SCRIPT_VERSION}
#-    author          Vincent Ramos (https://github.com/Ramos04)
#-    license         N/A
#-
#================================================================
#  HISTORY
#     2019/08/13 : Ramos04 : Template Creation
# 
#================================================================
#  DEBUG OPTION
#    set -n  # Uncomment to check your syntax, without execution.
#    set -x  # Uncomment to debug this shell script
#
#================================================================
# END_OF_HEADER
#================================================================
set -euo pipefail
IFS=$'\n\t'

#============================
#  FUNCTIONS
#============================

  #== fecho function ==#
fecho() {
	_Type=${1} ; shift ;
	[[ ${SCRIPT_TIMELOG_FLAG:-0} -ne 0 ]] && printf "$( date ${SCRIPT_TIMELOG_FORMAT} ) "
	printf "[${_Type%[A-Z][A-Z]}] ${*}\n"
	if [[ "${_Type}" = CAT ]]; then
		_Tag="[O]"
		[[ "$1" == \[*\] ]] && _Tag="${_Tag} ${1}"
		if [[ ${SCRIPT_TIMELOG_FLAG:-0} -eq 0 ]]; then
			cat -un - | awk '$0="'"${_Tag}"' "$0; fflush();' ;
		elif [[ "${GNU_AWK_FLAG}" ]]; then # fast - compatible linux
			cat -un - | awk -v tformat="${SCRIPT_TIMELOG_FORMAT#+} " '$0=strftime(tformat)"'"${_Tag}"' "$0; fflush();' ;
		elif [[ "${PERL_FLAG}" ]]; then # fast - if perl installed
			cat -un - | perl -pne 'use POSIX qw(strftime); print strftime "'${SCRIPT_TIMELOG_FORMAT_PERL}' ' "${_Tag}"' ", gmtime();'
		else # average speed but resource intensive- compatible unix/linux
			cat -un - | while read LINE; do \
				[[ ${OLDSECONDS:=$(( ${SECONDS}-1 ))} -lt ${SECONDS} ]] && OLDSECONDS=$(( ${SECONDS}+1 )) \
				&& TSTAMP="$( date ${SCRIPT_TIMELOG_FORMAT} ) "; printf "${TSTAMP}${_Tag} ${LINE}\n"; \
			done 
		fi
	fi
}

  #== custom function ==#
# All user defined functions should be placed here


#============================
#  ALIAS AND FUNCTIONS
#============================

  #== error management functions ==#
info() { fecho INF "${*}"; }
warning() { [[ "${flagMainScriptStart}"  -eq 1 ]] && ipcf_save "WRN" "0" "${*}" ; fecho WRN "WARNING: ${*}" 1>&2 ; }
error() { [[ "${flagMainScriptStart}" -eq 1 ]] && ipcf_save "ERR" "0" "${*}" ; fecho ERR "ERROR: ${*}" 1>&2 ; }
debug() { [[ ${flagDbg} -ne 0 ]] && fecho DBG "DEBUG: ${*}" 1>&2; }

tag() { [[ "x$1" == "x--eol" ]] && awk '$0=$0" ['$2']"; fflush();' || awk '$0="['$1'] "$0; fflush();' ; }
infotitle() { _txt="-==# ${*} #==-"; _txt2="-==#$( echo " ${*} " | tr '[:print:]' '#' )#==-" ;
	info "$_txt2"; info "$_txt"; info "$_txt2"; 
}

  #== startup and finish functions ==#

  #== usage functions ==#
usage() { printf "Usage: "; scriptinfo usg ; }
usagefull() { scriptinfo ful ; }
scriptinfo() { headFilter="^#-"
	[[ "$1" = "usg" ]] && headFilter="^#+"
	[[ "$1" = "ful" ]] && headFilter="^#[%+]"
	[[ "$1" = "ver" ]] && headFilter="^#-"
	head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }

#============================
#  FILES AND VARIABLES
#============================

  #== general variables ==#
SCRIPT_VERSION="0.0.1"
SCRIPT_NAME="$(basename ${0})" 				# scriptname without path
SCRIPT_DIR="$( cd $(dirname "$0") && pwd )" 		# Script Directory
SCRIPT_ROOT="${SCRIPT_DIR%/*}"				# Add a /* depending on depth of the script folder in the root. 
SCRIPT_TEMP_DIR=$SCRIPT_DIR"/tmp" 			# Where to create temp folder
SCRIPT_TEMP_DIR=$SCRIPT_DIR"/<name>.tmp" 		# Need to insert filename in this one
SCRIPT_FULLPATH="${SCRIPT_DIR}/${SCRIPT_NAME}"		# Full path of the script
HOSTNAME="$(hostname)"					# Hostname
FULL_COMMAND="${0} $*"					# Full command

  #== date variables ==#
SCRIPT_DATE_FORMAT="+%Y%m%d"
SCRIPT_EXEC_DATE=$(date ${SCRIPT_DATE_FORMAT})
SCRIPT_LOG_TIMESTAMP="$(date)"

  #== information variables ==#
EXEC_ID=${$}
SCRIPT_HEADSIZE=$(grep -sn "^# END_OF_HEADER" ${0} | head -1 | cut -f1 -d:)



  #== file variables ==#
fileLog="/dev/null"

  #== option variables ==#
flagOptErr=0

  #== function variables ==#
# Define variables that will be used in funcitons

#============================
#  PARSE OPTIONS WITH GETOPTS
#============================
  #== set short options ==#
SCRIPT_OPTS='hv-:'
SCRIPT_OPTS_COUNT=2

  #== set long options associated with short one ==#
typeset -A ARRAY_OPTS
ARRAY_OPTS=(
	[help]=h
	[man]=h
	[version]=v
)

  #== parse options ==#
while getopts ${SCRIPT_OPTS} OPTION ; do
	#== translate long options to short ==#
	if [[ "x$OPTION" == "x-" ]]; then
		LONG_OPTION=$OPTARG
		LONG_OPTARG=$(echo $LONG_OPTION | grep "=" | cut -d'=' -f2)
		LONG_OPTIND=-1
		[[ "x$LONG_OPTARG" = "x" ]] && LONG_OPTIND=$OPTIND || LONG_OPTION=$(echo $OPTARG | cut -d'=' -f1)
		[[ $LONG_OPTIND -ne -1 ]] && eval LONG_OPTARG="\$$LONG_OPTIND"
		OPTION=${ARRAY_OPTS[$LONG_OPTION]}
		[[ "x$OPTION" = "x" ]] &&  OPTION="?" OPTARG="-$LONG_OPTION"
		
		if [[ $( echo "${SCRIPT_OPTS}" | grep -c "${OPTION}:" ) -eq 1 ]]; then
			if [[ "x${LONG_OPTARG}" = "x" ]] || [[ "${LONG_OPTARG}" = -* ]]; then 
				OPTION=":" OPTARG="-$LONG_OPTION"
			else
				OPTARG="$LONG_OPTARG";
				if [[ $LONG_OPTIND -ne -1 ]]; then
					[[ $OPTIND -le $Optnum ]] && OPTIND=$(( $OPTIND+1 ))
					shift $OPTIND
					OPTIND=1
				fi
			fi
		fi
	fi

	#== options follow by another option instead of argument ==#
	if [[ "x${OPTION}" != "x:" ]] && [[ "x${OPTION}" != "x?" ]] && [[ "${OPTARG}" = -* ]]; then 
		OPTARG="$OPTION" OPTION=":"
	fi

	#== manage options ==#
	case "$OPTION" in
		
		h ) usagefull; echo $2;
			exit 0
		;;
		
		v ) scriptinfo
			exit 0
		;;
		
		: ) error "${SCRIPT_NAME}: -$OPTARG: option requires an argument"
			flagOptErr=1
		;;
		
		? ) error "${SCRIPT_NAME}: -$OPTARG: unknown option"
			flagOptErr=1
		;;
	esac
done
shift $((${OPTIND} - 1)) ## shift options

#============================
#  MAIN SCRIPT
#============================

  #== Check for flag argument erros ==#
#[ $flagOptErr -eq 1 ] && usage 1>&2 && exit 1 ## print usage if option error and exit
[ $flagOptErr -eq 1 ] && exit 1 ## print usage if option error and exit

  #== Check/Set arguments ==#
[[ $# -gt "$SCRIPT_OPTS_COUNT" ]] && error "${SCRIPT_NAME}: Too many arguments" && usage 1>&2 && exit 2


  #== Main part ==#
  #===============#


  #===== End =====#
  #===============#
