sudo su - root
sudo rm /var/lib/dpkg/updates/*
sudo apt-get update
sudo apt upgrade sonaric -y

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/monk-io/sonaric-install/main/linux-install-sonaric.sh)"
