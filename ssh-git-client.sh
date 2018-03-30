#!/usr/bin/env bash

config_file=~/.ssh-git-client.config
id_file=~/.ssh/id_rsa_git

. $config_file

if [ ! -f $config_file ]; then
  echo "Configuring ssh-git-client for the first time"
  
  # Create a config file
  touch $config_file
  echo -n "git server: "
  read gitserver
  echo "gitserver=\"$gitserver\"" >> $config_file
  
  cat ~
fi

if [ "$gitserver" == "" ]; then
  echo "gitserver not configured"
  exit 1
fi

echo "git server: $gitserver"

# Check and generate id file
if [ ! -f ${id_file}.pub ]; then  

  mkdir -p ~/.ssh
  ssh-keygen -t rsa -f $id_file
  
  cat ${id_file}.pub | ssh $gitserver "mkdir -p ~./ssh && cat >> ~/.ssh/authorized_keys"
    
fi

ssh_cmd="ssh -i $id_file $gitserver"

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
  
  echo "Checking repositories"
  repo=$($ssh_cmd "ls /git/ | grep ${name}.git")  
  if [ "$?" == "0" ]; then
    echo "Repository already exists!"
    exit 1
  fi
  
  cmd="$ssh_cmd \"mkdir -p /git/${name}.git && git init --bare /git/${name}.git\""
  run_cmd $cmd
  echo "-----------------"
  echo "git clone ${gitserver}:/git/${name}.git"
  echo "or"
  echo "git remote add origin ${gitserver}:/git/${name}.git"
}

if [ -z "$1" ]; then
  echo "USAGE: $0 COMMAND"
  exit 1
fi

cmd=$1

if [ $cmd == "create-repo" ]; then

  if [ -z "$2" ]; then
    echo "USAGE: $0 create-repo NAME"
    exit 1
  fi
  
  name=$2

  create_repo $name

fi
