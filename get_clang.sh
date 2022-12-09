#!/bin/bash

# Try to detect if running on Windows with some non-standard or non-compliant
# Shell interpreter.
IS_WINDOWS=0

echo "$PATH" | grep -i "Windows" &>/dev/null
if [[ $? -eq 0 ]]
then
    echo "[debug] 'PATH' contains 'Windows' stuff!" >&2
    IS_WINDOWS=1
fi

if [[ ! -z "$windir" || ! -z "$WINDIR" ]]
then
    echo "[debug] Found 'windir' variable!" >&2
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


# Normal entry point, start checking if invocation or the environment is sane.
if [[ $# -lt 1 || $# -gt 2 ]]
then
    echo "Usage: $0 <your-mainstream-username>"
    exit 1
fi

if [[ $1 == "CodeCheckerGroup" ]]
then
    echo "[error] Cloning from 'CodeCheckerGroup/llvm-project.git' is forbidden!" >&2
    echo "You do not have access to work in the 'upstream' repository." >&2
    echo "Please read the 'How to get involved?' help at " >&2
    echo "    http://mainstream.inf.elte.hu/CodeCheckerGroup/CodeChecker/blob/master/README.md" >&2
    echo "and then create a fork on the website http://mainstream.inf.elte.hu" >&2
    echo "" >&2
    echo "Then run the script again with YOUR mainstream username as the first argument!" >&2
    exit 1
fi





WHERE_AM_I=$(pwd)
if [[ -z "${WHERE_AM_I}" ]]
then
    echo "[critical fail] Script attempted to run on a fucked up system, where I can't even" >&2
    echo "query which directory the script is running at..." >&2
    echo "" >&2
    echo "Please consider using an operating system developed after 1960!" >&2
    exit 1
fi

HAS_ANY_MANDATORY_PROGRAMS_MISSING=0
command -v ssh &>/dev/null
if [[ $? -ne 0 ]]
then
    echo "[error] 'ssh' command not found on the system. Can't connect otherwise!" >&2
    HAS_ANY_MANDATORY_PROGRAMS_MISSING=1
fi

command -v git &>/dev/null
if [[ $? -ne 0 ]]
then
    echo "[error] 'git' command not found on the system. The project code can't be accessed without it!" >&2
    HAS_ANY_MANDATORY_PROGRAMS_MISSING=1
fi

command -v cmake &>/dev/null
if [[ $? -ne 0 ]]
then
    echo "[error] 'cmake' command not found. You can't build without it!" >&2
    HAS_ANY_MANDATORY_PROGRAMS_MISSING=1
fi

command -v ninja &>/dev/null
if [[ $? -ne 0 ]]
then
    echo "[error] 'ninja' command not found. You can't build without it!" >&2
    HAS_ANY_MANDATORY_PROGRAMS_MISSING=1
fi

if [[ ${HAS_ANY_MANDATORY_PROGRAMS_MISSING} -ne 0 ]]
then
    echo "[critical fail] One or more mandatory programs are not installed on the system!" >&2
    exit 1
fi




if [[ ! -d "${WHERE_AM_I}/llvm-project" ]]
then
    echo "Checking connectivity and access to mainstream.inf.elte.hu..."
    echo ""
    echo ""
    HAS_SSH_KEY=1

    # GitLab only supports SSH-based authentication
    ssh git@mainstream.inf.elte.hu -o PasswordAuthentication=no -o NumberOfPasswordPrompts=0 &>/dev/null
    if [[ $? -ne 0 ]]
    then
        HAS_SSH_KEY=0
        echo "Connection to 'mainstream.inf.elte.hu' with current configuration" >&2
        echo "failed automatically." >&2
        echo "" >&2
        echo "Trying to see if I can figure out whether you have the right config..." >&2
    fi

    if [[ ${HAS_SSH_KEY} -eq 0 ]]
    then
        if [[ ! -d "${HOME}/.ssh" ]]
        then
            echo "[error] You don't even have the '.ssh' directory in your home..." >&2
            exit 1
        fi

        CHECK_SSH_CFG=0
        if [[ ! -f "${HOME}/.ssh/id_rsa" ]]
        then
            echo "Default SSH key at '${HOME}/.ssh/id_rsa' not found..." >&2
            CHECK_SSH_CFG=1
        fi

        GREP_RESULT=$(grep "mainstream.inf.elte.hu" ${HOME}/.ssh/config 2>/dev/null)
        if [[ ${CHECK_SSH_CFG} -eq 1 && -z "${GREP_RESLT}" ]]
        then
            echo "" >&2
            echo "" >&2
            echo "Any reference to 'mainstream.inf.elte.hu' in SSH clientside config" >&2
            echo "file '${HOME}/.ssh/config' not found -- assuming no key was" >&2
            echo "set up for connection..." >&2
        fi

        echo ""
        echo ""
        echo "[error] I don't think you've set it up right. No connection can be made." >&2
        echo "" >&2
        echo "Please check your internet connection first. If there is link, please execute:" >&2
        echo "" >&2
        echo "    ssh git@mainstream.inf.elte.hu " >&2
        echo "" >&2
        echo "and give the password of YOUR SSH KEY (if there is any, not your e-mail or Neptun password!)" >&2
        echo "" >&2
        echo "Then try this script again..." >&2

        exit 1
    fi


    echo ""
    echo ""
    echo "Getting source from mainstream.inf.elte.hu for: $1"
    echo "This might take a VERY long time ... !"
    git clone git@mainstream.inf.elte.hu:$1/llvm-project.git --origin origin
    if [[ $? -ne 0 ]]
    then
        echo "[critical fail] git clone on fork failed. Did you fork under your own username?" >&2
        exit 1
    fi

    echo ""
    echo "Setting up remote for teacher-curated source from mainstream.inf.elte.hu"
    echo "This should be quick, if the previous thing finished successfully!"
    cd "${WHERE_AM_I}/llvm-project"
    git remote add upstream git@mainstream.inf.elte.hu:CodeCheckerGroup/llvm-project.git
    git fetch upstream
    if [[ $? -ne 0 ]]
    then
        echo "[warning] git fetch on teacher-curated mirror failed. This should not have happened!" >&2
        echo "Your own fork still seems to be properly cloned... we continue on." >&2
    fi

    echo "[success] Source code has been obtained successfully."
    cd ${WHERE_AM_I}
else
    echo "'llvm-project' seems to had already been cloned."
fi





if [[ ! -d "${WHERE_AM_I}/Build" ]]
then
    echo ""
    echo ""
    echo "Creating build directory..."
    mkdir Build
    cd "${WHERE_AM_I}/Build"

    echo ""
    echo ""
    echo "Running 'cmake' for build generation..."

    #
    # If you want to build static libs, use:  -DBUILD_SHARED_LIBS=OFF
    # This will increase the size of the binaries significantly and also increase the
    # linking time. The resulting binaries, however, will be faster.
    #
    # Also note that, shared libs are not working on Windows.
    #
    # Uncomment the end of line if you have libedit installed.
    #
    # If you have the gold linker installed, use that. It is faster than the
    # standard ld linker. Add -DLLVM_USE_LINKER=gold to use gold.
    #
    # If you want to limit the number of link jobs use: -DLLVM_PARALLEL_LINK_JOBS=2
    #
    # If you want to build tests by default use: -DLLVM_BUILD_TESTS=ON
    #
    # If the toolchain is recent enough, build times can be further improved
    # by splitting the debug info into spearate files using:
    # -DLLVM_USE_SPLIT_DWARF=ON
    # More info on split-dwarf: http://www.productive-cpp.com/improving-cpp-builds-with-split-dwarf/
    #
    cmake \
      -G "Ninja" \
      -DLLVM_ENABLE_PROJECTS="llvm;clang;clang-tools-extra" \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DBUILD_SHARED_LIBS=ON \
      -DLLVM_TARGETS_TO_BUILD=X86 \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
      -DLLVM_ENABLE_ASSERTIONS=ON \
      -DLLVM_ENABLE_BINDINGS=OFF \
      -DLLVM_USE_LINKER=gold \
      -DLLVM_USE_RELATIVE_PATHS_IN_FILES=ON \
      ${WHERE_AM_I}/llvm-project/llvm/ # -DCMAKE_CXX_FLAGS="-DHAVE_LIBEDIT" -DCMAKE_EXE_LINKER_FLAGS="-ledit"

    cd ${WHERE_AM_I}
    # Symlink compile_commands.json in the parent (root) directory of the
    # project so that LSP servers such as clangd can identify the build
    # properly.
    ln -s Build/compile_commands.json ./compile_commands.json

    echo "[success] Build configured. Now you can work!"
    echo ""
    echo "    The Git SOURCE code repository is available at \"${WHERE_AM_I}/llvm-project\""
    echo "    The BUILD directory where the binaries are produced is at \"${WHERE_AM_I}/Build\""
else
    echo "Build directory had already been created too. You should be working by now."
    echo ""
    echo ""
    echo "If you want to force a re-build, please do"
    echo "    rm -r ${WHERE_AM_I}/Build"
    echo ""
    echo "[warning] Your build configuration and your built project WILL BE LOST."
    echo "[warning] A full re-build will be executed, and it might take hours!"
fi


 