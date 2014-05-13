#!/bin/bash

usage()
{
cat << EOF
usage: $0 options

This script handles renaming of log bundles with a unique prefix for use with the splunk forwarder

OPTIONS:
   -h      Show this message
   -p      Filename prefix that all logfiles will recieve
   -i      Input file - a rallylogs.tar.gz log bundle
EOF
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
inputfile=""
prefix=""

while getopts "h?p:i:" opt; do
    case "$opt" in
    h|\?)
        usage
        exit 0
        ;;
    p)  prefix=$OPTARG
        ;;
    i)  inputfile=$OPTARG
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "prefix=$prefix, inputfile=$inputfile, Leftovers: $@"

if [[ -z $prefix ]] || [[ -z $inputfile ]]
then
     usage
     exit 1
fi

basedir=`pwd`
tar zxvf $inputfile

# Exploding the $inputfile should have created a var tree
if [ -d ./var ]; then
	cd var
	for log in `find ./ -name "*gz" -print`
	do
		echo "gunzipping $log..."
		gunzip $log
	done
	cd $basedir
fi

dirs=( ./var/log/domains/alm/logs ./var/log/domains/analytics/logs ./var/log/domains/solr/logs ./var/log/httpd )

for dir in ${dirs[@]}
do
    if [ -d $dir ]; then
    	cd $dir
    	for file in `ls`
    	do
            newname="${prefix}_${file}"
            echo "renaming $file to $newname..."
            mv $file $newname
    	done
    	cd $basedir
    fi
done

echo "Re-tarring var directory tree"
tar cvf "${prefix}_rallylogs.tar" var

echo "gzipping tarball"
gzip "${prefix}_rallylogs.tar"

echo "Cleaning up..."
rm -rf var

echo "Finished!"
