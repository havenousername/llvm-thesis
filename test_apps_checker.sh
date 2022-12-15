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
    echo "[warn] Usage of script '$0 <folder with c/c++ test files> <checks(optional?)> <max_file_count(optional)> <has_profile(optional)>'"
    exit 1
fi

dst=$1
max_file_count=10000
has_profile=1
checks=cert-assignments-in-selection

if [[ $# -ge 2 ]]
then
    checks=$2
fi 

if [[ $# -ge 3 ]]
then 
    max_file_count=$3
fi

if [[ $# -eq 4 ]]
then 
    has_profile=$4
fi


first_write=0
array=()
WHERE_AM_I=$(pwd)
# OUTPUT_DIR=`${WHERE_AM_I}/assignment-checker-out`
# get directories which are in the current dir and specified by the user
get_current_directories() {
    i=0
    for file in *; 
    do
        if [[ -d "$file" ]] && [[ "$file" == "$dst" ]]
        then 
            array[i]=$file
            i=$i+1
            sleep 0.4
        fi
    done   
}

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
get_current_directories

# Main program
for file in ${array[@]};
do
    echo "[info] Starting executing folder './${file}'"
    
    # cfiles=$(find ${WHERE_AM_I}/${file} -type f \
    #     -name "*.c" -o \
    #     -name "*.cpp" -o \    
    #     -name "*.cc" -o \ 
    #     -name "*.h"  -o \ 
    #     -name "*.C" -o \ 
    #     -name "*.cxx" -o \  
    #     -name "*.c++" \ 
    #     -o -name "*.hh" \    
    #     -o -name "*.hxx" \
    #     -o -name "*.hpp" 
    #     -o -name ".h++")
    cfiles=`find ${WHERE_AM_I}/${file} -type f -name "*.c" -o -name "*.cpp" -o -name "*.cc" -o -name "*.h"  -o -name "*.C" -o -name "*.cxx" -o -name "*.c++" -o -name "*.hh" -o -name "*.hxx" -o -name "*.hpp" -o -name ".h++"`
    
    for cfile in $(echo $cfiles | tr " " "\n")
    do
        if [[ max_file_count -eq 0 ]]
        then 
            exit 0
        fi
        max_file_count=$max_file_count-1

        sleep 0.0001
        echo "[info] Starting clang script on file ${cfile}"

        if [[ first_write -eq 0 ]]
        then 
            rm -rf .tmp/profile
        fi 
        mkdir -p .tmp 
        result=$(${WHERE_AM_I}/Build/bin/clang-tidy ${cfile} --enable-check-profile --store-check-profile=.tmp/profile  --quiet -checks=-*,${checks})
        touch .tmp/out.txt
        if [[ has_profile -eq 1 ]] || [[ "$result" == *"[cert-assignments-in-selection]"* ]]; 
        then 
            if [ -s .tmp/out.txt ] && [[ first_write -eq 0 ]]
            then
                echo "${result}" > .tmp/out.txt
                first_write=1
            else     
                echo "${result}" >> .tmp/out.txt
            fi 
        fi
    done 
    echo "[info] Finishing clang script on file ${cfile}"
done
