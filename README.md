GOS (Git Over SSH), A bash client script for administration of a personal ssh based git server

On the server:
```
sudo useradd git
sudo passwd git
sudo mkdir /home/git
sudo chown git:git /home/git
sudo ln -s <your_repo_dir> /git
chown git:git <your_repo_dir>
```

On the client:

Configure gos (first time only):
```
ssh-git-client/gos.sh
```

This creates `~/.gos.config` and `~/.ssh/id_rsa` and adds a `gos` alias to `~/.bashrc`

If `~/.ssh/id_rsa` was created it is also added to authorized keys on the server

Usage:
```
gos add-key                  (Add public key to authorized keys on the git server)
gos list
gos create <name>
gos remove <name>
gos rename <current name> <new name>
```
