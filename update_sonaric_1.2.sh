sudo su - root
ps -ef | grep upgrade | grep -v grep | awk '{print $2}' | xargs kill -9
apt update
apt upgrade sonaric -y
