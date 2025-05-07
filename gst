#!/usr/bin/env bash

function _tty_reverse()
{
    if [ -t 1 ] ; then
        tput -Txterm smul || true
    fi
}

function _tty_bold()
{
    if [ -t 1 ] ; then
        tput -Txterm bold || true
    fi
}

function _tty_yellow()
{
    if [ -t 1 ] ; then
        tput -Txterm setaf 3 || true
    fi
}

function _tty_green()
{
    if [ -t 1 ] ; then
        tput -Txterm setaf 2 || true
    fi
}

function _tty_red()
{
    if [ -t 1 ] ; then
        tput -Txterm setaf 1 || true
    fi
}

function _tty_clear()
{
    if [ -t 1 ] ; then
        tput -Txterm sgr0 || true
    fi
}

function _get_remote_branch()
{
    output=$(git rev-parse --symbolic-full-name --abbrev-ref @{u} 2>/dev/null)
    errcode=$?

    if (( errcode == 0 )); then
        echo $output
    fi
}

function _section_header()
{
    _tty_clear
    _tty_reverse
    _tty_bold
    echo "$1"
    _tty_clear
}

function _gitst()
{
    _section_header Config
    echo "user.name  " $(git config user.name)
    echo "user.email " $(git config user.email)
    echo;

    _section_header Branch
    cur_branch_name=$(git rev-parse --abbrev-ref HEAD)
    remote_branch=$(_get_remote_branch)
    if [ -n "$remote_branch" ]; then
        remote_branch=" --> [${remote_branch}]"
    else
        _tty_red
        _tty_bold
        remote_branch=" (no remote)"
    fi
    echo $cur_branch_name"$remote_branch"
    _tty_clear

    echo;
    _section_header "Local status"

    status=$(git status -sb $1)
    status_first_line=$(git status -sb | head -1)
    if [ "$status" == "## $cur_branch_name" ]; then
        _tty_green
        echo "$status"
        echo "(no changes detected)"
    else
        _tty_bold
        _tty_red
        echo "$status"
    fi

    echo
    _section_header "Last commit"
    str=$(git log -1)
    echo "$str"
    echo

    _section_header "Remotes"
    git remote -v show
}

_tty_yellow
git fetch
_tty_clear

_gitst $1
