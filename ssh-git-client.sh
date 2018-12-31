#!/usr/bin/env bash

config_file=~/.gos.config
id_file=~/.ssh/id_rsa

if [ -f $config_file ]; then
. $config_file
fi

if [ ! -f $config_file ]; then
  echo "Configuring ssh-git-client for the first time"
  
  # Create a config file
  echo -n "git server (git@hostname): "
  read gitserver
  echo "gitserver=\"$gitserver\"" > $config_file
  
  currentdir=$(pwd)
  echo "alias gos=\"${currentdir}/$0\"" >> ~/.bashrc
fi

if [ "$gitserver" == "" ]; then
  echo "gitserver not configured"
  exit 1
fi

function add_authorized_key {
  
  cat ${id_file}.pub | ssh $gitserver "mkdir -p ~./ssh && cat >> ~/.ssh/authorized_keys"
}

# Check and generate id file
if [ ! -f ${id_file}.pub ]; then

  mkdir -p ~/.ssh
  ssh-keygen -t rsa -f $id_file

  add_authorized_key
fi

ssh_cmd="ssh -i $id_file $gitserver"

function display_help_message {

  echo "usage: $0 command"
  echo "commands:"
  echo "help"
  echo "list"
  echo "create repo-name"
  echo "remove repo-name"
  echo "add-key"
}

function run_cmd {

  if [ "$TEST" == "" ]; then      
    echo $cmd
    eval $cmd
  else
    echo "TEST: $cmd"
  fi
}

function create_repo {

  name=$1

  repo=$($ssh_cmd "ls /git/ | grep ${name}.git")
  if [ "$?" == "0" ]; then
    echo "Repository already exist!"
    exit 1
  fi

  cmd="$ssh_cmd \"mkdir -p /git/${name}.git && git init --bare /git/${name}.git\""
  run_cmd $cmd
  echo "-----------------"
  echo "git clone ${gitserver}:/git/${name}.git"
  echo "or"
  echo "git remote add origin ${gitserver}:/git/${name}.git"
}

function remove_repo {

  name=$1

  repo=$($ssh_cmd "ls /git/ | grep ${name}.git")
  if [ "$?" != "0" ]; then
    echo "Repository does not exist!"
    exit 1
  fi

  echo -n "Are you sure you want to remove repository ${name}.git? [y/N] "
  read yesorno
  if [ "$yesorno" != "y" ]; then
    echo "Aborting"
    exit 0
  fi

  cmd="$ssh_cmd \"rm -rf /git/${name}.git\""
  run_cmd $cmd
}

if [ -z "$1" ]; then
  display_help_message
  exit 1
fi

cmd=$1
if [ $cmd == "help" ]; then

  display_help_message

elif [ $cmd == "list" ]; then

  eval $ssh_cmd "ls /git | sed 's/\(.*\).git/\1 $gitserver:\/git\/\1.git/g' | column -tx"

elif [ $cmd == "create" ]; then

  if [ -z "$2" ]; then
    echo "USAGE: $0 create-repo NAME"
    exit 1
  fi
  
  name=$2

  create_repo $name

elif [ $cmd == "remove" ]; then

  if [ -z "$2" ]; then
    echo "USAGE: $0 create-repo NAME"
    exit 1
  fi

  name=$2

  remove_repo $name

elif [ $cmd == "add-key" ]; then

  add_authorized_key

else

  display_help_message
  exit 1
fi
