
# sets up a non root user, installs and runs opera.
# taken and modified from: https://docs.fantom.foundation/staking/how-to-run-a-validator-node

# ./validatorSetup.sh <username>
# ./validatorSetup.sh myOperaUser

if [ $# -lt 1 ]; then
    echo "Please pass in at least a username to create"
    exit
fi

USER=$1

# Install required packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y build-essential git wget tar

# Create a non-root user
if id "$USER" &>/dev/null; then
  echo "$USER user already exists"
  sudo rm -rf /home/$USER
else
  echo "creating user: $USER"
  sudo useradd -m $USER
fi

# Setup ssh
sudo mkdir -p /home/$USER/.ssh
sudo cp ~/.ssh/authorized_keys /home/$USER/.ssh/authorized_keys

# Setup permissions
sudo usermod -aG sudo $USER
sudo chown -R $USER:$USER /home/$USER/
sudo chmod 700 /home/$USER/.ssh
sudo chmod 644 /home/$USER/.ssh/authorized_keys

FILE=/etc/sudoers.d/dont-prompt-$USER-for-password
if ! test -f "$FILE"; then
  echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee $FILE
fi

cd home/$USER/go
wget https://raw.githubusercontent.com/mhetzel/fantom-opera-validator/main/docker-compose.yml
