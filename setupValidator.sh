
# sets up a non root user, installs and runs opera.
# taken and modified from: https://docs.fantom.foundation/staking/how-to-run-a-validator-node

# ./validatorSetup.sh <username>
# ./validatorSetup.sh <username> <opera version>
# ./validatorSetup.sh myOperaUser
# ./validatorSetup.sh myOperaUser 1.0.2-rc.5

if [ $# -lt 1 ]; then
    echo "Please pass in at least a username to create"
    exit
fi

if [ $# -eq 2 ]; then
    OPERA_VERSION="$2"
else
    OPERA_VERSION='1.0.2-rc.5'
fi

USER=$1

GO_VERSION='go1.15.10'

# Install required packages
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y zsh build-essential git wget tar

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

# Define Paths
GOROOT=/usr/local/go
GOPATH=/home/$USER/go
OPERAPATH=/home/$USER/go-opera
OPERAURL=https://github.com/Fantom-foundation/go-opera.git
PATHS=$GOPATH/go/bin:$GOROOT/bin:$OPERAPATH/build
BASHPROFILE=/home/$USER/.bash_profile

# Setup bash environment for running remaining setup
echo "export GOROOT=$GOROOT" | sudo tee -a $BASHPROFILE
echo "export GOPATH=$GOPATH" | sudo tee -a $BASHPROFILE
echo "export GO_VERSION=$GO_VERSION" | sudo tee -a $BASHPROFILE
echo "export OPERAPATH=$OPERAPATH" | sudo tee -a $BASHPROFILE
echo "export OPERAURL=$OPERAURL" | sudo tee -a $BASHPROFILE
echo "export OPERA_VERSION=$OPERA_VERSION" | sudo tee -a $BASHPROFILE
echo "export PATH=$PATH:$PATHS" | sudo tee -a $BASHPROFILE

# Switch to new user to continue setup
sudo su - $USER --shell /bin/bash <<- 'EOT'
  # Check go installtion and install if needed
  INSTALLED_GO=$(go version)
  if [[ ! -z "$INSTALLED_GO" && "$INSTALLED_GO" == *"$GO_VERSION"* ]]
  then
    echo "go is already installed"
  else
    GO_FILE=$GO_VERSION.linux-amd64.tar.gz
    wget https://dl.google.com/go/$GO_FILE
    sudo rm -rf $GOROOT
    sudo tar -xf $GO_FILE -C /usr/local
  fi
  # Validate go version before moving on
  INSTALLED_GO=$(go version)
  echo $INSTALLED_GO
  if [[ ! -z "$INSTALLED_GO" && "$INSTALLED_GO" == *"$GO_VERSION"* ]]
  then
    # Check opera installtion and install if needed
    INSTALLED_OPERA=$(opera help)
    if [[ ! -z "$INSTALLED_OPERA" && "$INSTALLED_OPERA" =~ .*"$OPERA_VERSION".* ]]
    then
      echo "opera is already installed"
    else
      # Install opera
      git clone $OPERAURL $OPERAPATH
      cd $OPERAPATH
      git checkout release/$OPERA_VERSION
      make
      cd build
      wget https://opera.fantom.network/mainnet.g
      cd ~
    fi
    # Validate opera version before moving on
    INSTALLED_OPERA=$(opera version)
    echo $INSTALLED_OPERA
    if [[ ! -z "$INSTALLED_OPERA" && "$INSTALLED_OPERA" =~ .*"$OPERA_VERSION".* ]]
    then
      echo "opera seems good. close this window and open a new ssh session with $USER"
    else
      echo "opera did not install for some reason"
    fi
  else
    echo "go did not install for some reason"
  fi
EOT
