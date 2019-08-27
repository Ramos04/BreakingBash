#!/bin/bash
function usage {
	cat <<EOM
Usage: $(basename "$0") [OPTION]...

  -a VALUE    argument description
              line two
              line three
  -b VALUE    argument description
  -c          switch description
              line two
  -d          switch description
              line two
              line three
              line four
  -h          display help
EOM

	exit 2
}

# init switch flags
c=0
d=0

while getopts ":a(apple):b:cdh" optKey; do
	case "$optKey" in
		a)
			a=$OPTARG
			;;
		b)
			b=$OPTARG
			;;
		c)
			c=1
			;;
		d)
			d=1
			;;
		h|*)
			usage
			;;
	esac
done

shift $((OPTIND - 1))

echo "Processed:"
echo "a=$a"
echo "b=$b"
echo "c=$c"
echo "d=$d"
echo

echo "A total of $# args remain:"
echo "$*"
