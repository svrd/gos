A bash client script for administrating a personal ssh based git server

On the server:
sudo useradd git
sudo passwd git
sudo mkdir /home/git
sudo chown git:git /home/git
sudo ln -s your_repo_dir /git
chown git:git your_repo_dir

Configure git-client (first time only):
ssh-git-client/ssh-git-client.sh

This creates
~/.ssh-git-client.config
and
~/.ssh/id_rsa

Usage:
git-client create-repo a-test-repo
git-client list-repos
git-glient remove-repo a-test-repo

