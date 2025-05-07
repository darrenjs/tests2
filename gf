#!/usr/bin/env bash

# Note: the tricky part with this script is dealing with searchterms and paths
# that have spaces within them.  It is not clear what is the best way to
# handle lists of such parameters, so this script has been arrived at via a
# trial and error processes.  Notably there are different ways in bash to
# treat lists of strings (that contain embedded spaces):
#
#  - Variable  $* and "$*"
#
#  - Variable  $@ and "$@"
#
#  - Executing a command directly, or, via eval
#
#  - Parsing position parameters via "for word; do" and shift
#
# -DJS 19/08/12

opt_i=""
opt_w=""
opt_F=""
opt_verbose=1

ink="\033[0;33m"
ink2="\033[0;32m"
noink="\033[0m"

##
## Util for printing a list.  The list is expanded to respect embedded spaces.
## Eg., if called with [ "int a" foo bar ] it will print three items, the
## first containing a space.
##
dumplist()
{
    echo -n "$1 "
    shift

    for word ; do
        echo -en "[${ink}${word}${noink}] "
    done
    echo
}


##
## Subroutine for invoking grep. As noted below, the grep command is invoked
## via this subroutine so that we can process the user's arguments using the
## shift command, which only operates on positional parameters.
run_find()
{
    # Use shift to obtain the searchterm - ie the thing we are going to look
    # for
    local searchterm="$1";
    shift;

    if [ "$opt_verbose" -ne 0  ]; then
        echo -ne searching for [${ink2}$searchterm${noink}] in paths
        dumplist "" "$@"
    fi

    if [ -z "$1" ];
    then
        # handle empty list of directories
        find . -type d -name .svn -prune -o ! -type d -exec \grep -Hn ${opt_i} ${opt_w} ${opt_F} --color "${searchterm}"   '{}' \;
    else
        # Note: this is suprising.  We can give find a list of paths to start
        # looking at, eg, "find path1 path2 path3", which is how do the
        # searching in multiple directories.
        find "$@" -type d -name .svn -prune -o ! -type d -exec \grep -Hn ${opt_i} ${opt_w} ${opt_F}  --color "${searchterm}"   '{}' \;
    fi
}


help()
{
    echo "Options"
    echo -e "  -i"\\tinvoke grep -i case insensitive search
    echo -e "  -w"\\tinvoke grep -w whole word search
    echo -e "  -v"\\tverbose
    exit 0
}


args=""

# Note: the "in" keyword is omitted in the for loop, which means we loop over
# the positional parameters.  This is better than doing "for word in $*",
# which has a problem because all of the parameters are expanded, ie, embedded
# spaces are lost.
#
# Note: it would be nice to identify grep switches and simply pass them
# on. However, there is no generic way to do this, since we don't know if a
# grep switch will be followed by a switch parameter, etc, -C 10.  So, any new
# grep switches we wish to support must be implemented manually in this
# section.
#

unset _have_searchterm;
unset _have_dirs;

for word ; do
    case $word in
        -v ) opt_verbose=1 ;;
        -i ) opt_i="-i" ;;
        -w ) opt_w="-w" ;;
        -F ) opt_F="-F" ;;
        -h ) help ;;
        --help )  help ;;
        -*) echo option [ ${word} ] not supported ; exit 1 ;;
        * ) args="$args \"$word\""
            if [ -z ${_have_searchterm} ]; then
                _have_searchterm=1;
            elif [ -z ${_have_dirs} ]; then
                _have_dirs=1;
            fi
            ;;
    esac
done

if [ -z ${_have_searchterm} ];
then
    echo search for what?
    exit 1
fi

# If the user has not supplied a directory name, then lets pretend they
# specified ".".  We don't really need to do this; we could have this special
# case inside of the run_find() function.  However, by making sure there will
# always be at least one item in the list of directories, we get more
# consistent output from the whole script (eg, when printing the paths to be
# displayed, now we will always have something to show).
if [ -z ${_have_dirs} ];
then
    args="$args \".\""
fi


# Now build a commandline, which is what we would enter at a bash
# prompt. Because we need to use the shift comand to access the initial
# parameter, we will invoke the find command via a function, so that our
# arguments in $arg can be processed as position parameters.

#echo args are :${args}:
cmdline="run_find ${args}"
eval $cmdline
