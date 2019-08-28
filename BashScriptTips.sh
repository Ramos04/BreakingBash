     ###################################################################
     #           ____     ______  ____    __  __                       #
     #          /\  _`\  /\  _  \/\  _`\ /\ \/\ \                      #
     #          \ \ \L\ \\ \ \L\ \ \,\L\_\ \ \_\ \                     #
     #           \ \  _ <'\ \  __ \/_\__ \\ \  _  \                    #
     #            \ \ \L\ \\ \ \/\ \/\ \L\ \ \ \ \ \                   #
     #             \ \____/ \ \_\ \_\ `\____\ \_\ \_\                  #
     #           ____/_____  ___/_____________/_/\____                 #
     #          /\  _`\ /\ \/\ \/\__  _\ /\  _`\ /\  _`\               #
     #          \ \ \L\_\ \ \ \ \/_/\ \/ \ \ \/\ \ \ \L\_\             #
     #           \ \ \L_L\ \ \ \ \ \ \ \  \ \ \ \ \ \  _\L             #
     #            \ \ \/, \ \ \_\ \ \_\ \__\ \ \_\ \ \ \L\ \           #
     #             \ \____/\ \_____\/\_____\\ \____/\ \____/           #
     #              \/___/  \/_____/\/_____/ \/___/  \/___/            #
     #                                                                 #
     ###################################################################

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

  #-----------------------------------------
  # Independent of current working directory
  #-----------------------------------------
CURR_DIR="$(dirname $0);"
printf -- 'moving application to /opt/app.jar';
mv "${CURR_DIR}/application.jar" /opt/app.jar;


  #----------------------------------
  # Check if a script is run as root
  #----------------------------------
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

  #-----------------
  # Static variables
  #-----------------
readonly tempVar="hello"

##########################
# DEBUGGING/SYNTAX CHECK
#################################################################

  #-----------------
  # Debugging mode
  #-----------------
  # Run the script with the following command
/bin/bash -v <script name>

  #-----------------
  # Syntax checking
  #-----------------
  # Run the script with the following command
/bin/bash -n <script name>

  #----------------
  # Script tracing
  #----------------
  # Run the script with the following command
sudo /bin/bash -x <script name>


##########################
# BEST PRACTICIES
#################################################################

  #-----------
  # FUNCTIONS
  #-----------
  # Don't use the function keyword. All variables created
  # in a function should be made local.

# WRONG
function foo {
    i=foo # this is now global, wrong depending on intent
}

# RIGHT
foo() {
    local i=foo # this is local, preferred
}

  #------------------
  # BLOCK STATEMENTS
  #------------------
# WRONG
if true
then
    ...
fi

# RIGHT
if true; then
    ...
fi

  #-----------------
  # TEST STATEMENTS
  #-----------------
  #Use [[ ... ]] for conditional testing, not [ .. ] or test ...

# WRONG
[ -d /etc ]

# RIGHT
[[ -d /etc ]]

  #-----------
  # SEQUENCES
  #-----------
  #Use bash builtins for generating sequences
n=10

# WRONG
for f in $(seq 1 5); do
    ...
done

# WRONG
for f in $(seq 1 "$n"); do
    ...
done

# RIGHT
for f in {1..5}; do
    ...
done

# RIGHT
for ((i = 0; i < n; i++)); do
    ...
done

  #---------------------
  # COMMAND SUBSTITUION
  #----------------------
  #Use $(...) for command substitution.

# WRONG
foo=`date`

# RIGHT
foo=$(date)

  #---------------------
  # COMMAND SUBSTITUION
  #----------------------
