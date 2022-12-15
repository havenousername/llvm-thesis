#! /bin/bash

# Don't run if it's on Windows
IS_WINDOWS=0

echo "$PATH" | grep -i "Windows" &>/dev/null
if [ $? -eq 0 ] 
then
    echo "[info] 'PATH' contains 'Windows'" >&2
    IS_WINDOWS = 1
fi 

if [[ ! -z "$windir" || ! -z "$WINDIR" ]]
then
    echo "[info] Found 'windir' variable!" >&2
    IS_WINDOWS=1
fi

if [[ $IS_WINDOWS -eq 1 ]]
then
    echo "" >&2
    echo "[fatal error] This script was designed to run in a" >&2
    echo "POSIX-compliant environment, preferably long-term stable" >&2
    echo "Debian or Ubuntu! It not only needs a proper Bash interpreter," >&2
    echo "but a full environment properly." >&2
    echo "" >&2
    echo "However, It appears that you are using Windows. Please do not!" >&2
    echo "" >&2
    echo "It is preferable to use a real Linux system, or at least WSL." >&2
    exit 1
fi


# Not enough arguments provided
if [[ $# -lt 1 || $# -gt 5 ]]
then 
    echo "[warn] Usage of script '$0 <folder with c/c++ test files> <has_profile(optional)> <checks(optional?)> <max_file_count(optional)>'"
    exit 1
fi

dst=$1
max_file_count=10000
has_profile=0
checks=cert-exp45-c

if [[ $# -ge 3 ]]
then
    checks=$3
fi 

if [[ $# -ge 4 ]]
then 
    max_file_count=$4
fi

if [[ $# -eq 2 ]]
then 
    has_profile=$2
fi


first_write=0
array=()
WHERE_AM_I=$(pwd)
# OUTPUT_DIR=`${WHERE_AM_I}/assignment-checker-out`
# get directories which are in the current dir and specified by the user

# Different error prone tests
check_build_dir() {
    if [ ! -d $1 ]
    then 
        echo "[error] Argument variable: $1 is not a directory name"
        echo ""
        echo "This script requires working directory with C/C++ files."
        echo "Please check your directory name and try again"
        echo ""
        exit 1
    fi

    if [ ! -d "${WHERE_AM_I}/Build" ] 
    then
        echo "[error] No Build directory in the root of the project!"
        echo ""
        echo "This script needs to have llvm binaries in the '/Build' directory"
        echo "Try to run 'get_clang.sh' file before running this script"
        echo ""
        exit 1 
    fi 

    if [ ! -d "${WHERE_AM_I}/Build/bin" ] || [ ! "${WHERE_AM_I}/Build/bin/clang-tidy" ]
    then
        echo "[error] No clang-tidy binary found"
        echo "" 
        echo "This script needs clang-tidy binary for the correct execution" 
        echo "Use this commands before:"
        echo "  cd build"
        echo "  ninja clang clang-tidy -j4"
        echo ""
        exit 1 
    fi 
}

check_build_dir
cd $dst
WHERE_AM_I_NOW=$(pwd)

directory=$(echo "$dst" | cut -d "/" -f2)

handle_files() {
    cfiles=("$@")
    for cfile in $(echo $cfiles | tr " " "\n")
    do
        if [[ max_file_count -eq 0 ]]
        then 
            exit 0
        fi
        max_file_count=$max_file_count-1

        # sleep 0.0001
        echo "[info] Starting clang script on file ${WHERE_AM_I_NOW}/${cfile}"

        if [[ first_write -eq 0 ]]
        then 
            rm -rf .tmp/profile
        fi 
        mkdir -p .tmp 
        echo $checks
        result=$(${WHERE_AM_I}/Build/bin/clang-tidy ${cfile} --enable-check-profile --store-check-profile=${WHERE_AM_I}/.tmp/profile  --quiet -checks=-*,${checks})
        touch "${WHERE_AM_I}/.tmp/out-${directory}.txt"
        chmod 777 "${WHERE_AM_I}/.tmp/out-${directory}.txt"
        if [[ has_profile -eq 1 ]] || [[ "$result" == *"[cert-exp45-c]"* ]]; 
        then 
            # if [[ "$result" == *"[clang-diagnostic-error]"* ]] || [[ -z "$result" ]] 
            # then
            #     continue  
            # fi 
            if [ -s $(${WHERE_AM_I}/.tmp/out-${directory}.txt) ] && [[ first_write -eq 0 ]]
            then
                echo "${result}" > "${WHERE_AM_I}/.tmp/out-${directory}.txt"
                first_write=1
            else     
                echo "${result}" >> "${WHERE_AM_I}/.tmp/out-${directory}.txt"
            fi 
        fi
    done 
}

# Main program
files_curr=`find ${WHERE_AM_I_NOW} -type f -name "*.c" -o -name "*.cpp" -o -name "*.cc" -o -name "*.h"  -o -name "*.C" -o -name "*.cxx" -o -name "*.c++" -o -name "*.hh" -o -name "*.hxx" -o -name "*.hpp" -o -name ".h++"`
handle_files "${files_curr[@]}"

cd $WHERE_AM_I
