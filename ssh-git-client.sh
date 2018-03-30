#!/usr/bin/env bash

config_file=~/.ssh-git-client.config
id_file=~/.ssh/id_rsa

. $config_file

if [ ! -f $config_file ]; then
  echo "Configuring ssh-git-client for the first time"
  
  # Create a config file
  touch $config_file
  echo -n "git server: "
  read gitserver
  echo "gitserver=\"$gitserver\"" >> $config_file
  
  currentdir=$(pwd)
  echo "alias gitclient=\"${currentdir}/$0\"" >> ~/.bashrc

fi

if [ "$gitserver" == "" ]; then
  echo "gitserver not configured"
  exit 1
fi

# Check and generate id file
if [ ! -f ${id_file}.pub ]; then  

  mkdir -p ~/.ssh
  ssh-keygen -t rsa -f $id_file

  cat ${id_file}.pub | ssh $gitserver "mkdir -p ~./ssh && cat >> ~/.ssh/authorized_keys"
fi

ssh_cmd="ssh -i $id_file $gitserver"

function display_help_message {

  echo "usage: $0 command"
  echo "commands:"
  echo "help"
  echo "list-repos"
  echo "create-repo repo-name"
  echo "remove-repo repo-name"
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

elif [ $cmd == "list-repos" ]; then

  eval $ssh_cmd "ls /git | sed 's/\(.*\).git/\1 $gitserver:\/git\/\1.git/g' | column -tx"

elif [ $cmd == "create-repo" ]; then

  if [ -z "$2" ]; then
    echo "USAGE: $0 create-repo NAME"
    exit 1
  fi
  
  name=$2

  create_repo $name

elif [ $cmd == "remove-repo" ]; then

  if [ -z "$2" ]; then
    echo "USAGE: $0 create-repo NAME"
    exit 1
  fi

  name=$2

  remove_repo $name

fi
