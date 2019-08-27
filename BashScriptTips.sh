#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# ^^^ BASH STRICT MODE
# -e 		Immediately exit upon any non-zero exit code, just like c exits 
#		after a seg fault or syntax error in python
# -u 		Throws an error and immediately exits when you refernce a 
#		variable that is undefined
# -o pipefail	Prevents errors in a pipeline from being masked
#
# IFS
# names=(
#   "Aaron Maxwell"
#   "Wayne Gretzky"
#   "David Beckham"
#   "Anderson da Silva"
# )
#
# WITHOUT STRICT                WITH STRICT-MODE IFS
# Aaron 			Aaron Maxwell
# Maxwell			Wayne Gretzky
# Wayne				David Beckham
# Gretzky			Anderson da Silva
# David
# Beckham
# Anderson
# da
# Silva

# Exit Traps
function finish {
  # Your cleanup code here
}
trap finish EXIT


# Provide --help flag
if [ ${#@} -ne 0 ] && [ "${@#"--help"}" = "" ]; then
  printf -- '...help...\n';
  exit 0;
fi;


# Checking if binaries exist
#-----------------------------------------
_=$(command -v docker);
if [ "$?" != "0" ]; then
  printf -- 'You don\t seem to have Docker installed.\n';
  printf -- 'Get it: https://www.docker.com/community-edition\n';
  printf -- 'Exiting with code 127...\n';
  exit 127;
fi;

# Independent of current working directory
#-----------------------------------------
CURR_DIR="$(dirname $0);"
printf -- 'moving application to /opt/app.jar';
mv "${CURR_DIR}/application.jar" /opt/app.jar;


