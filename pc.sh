
#Install java 8
#!/bin/bash
sudo apt update 
sudo apt install openjdk-8-jdk -y
#Samba
echo "*********Install samba*********"
sudo apt install samba -y
sudo mkdir -p /samba
sudo ufw allow samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bk
sudo cp smb.conf /etc/samba/
echo "*******samba done**********"

#install docker
echo "***********Install docker***********"
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce -y
sudo usermod -aG docker ${USER}
echo "*********docker is done**********"

#install james server
echo "*********install james server********"
sudo apt install bash-completion  
curl -O https://archive.apache.org/dist/james/server/apache-james-2.3.2.tar.gz
tar -xzf apache-james-2.3.2.tar.gz
sudo cp -r james-2.3.2 /opt
sudo cp phoenix.sh /opt/james-2.3.2/bin/
sudo chmod +x /opt/james-2.3.2/bin/*.sh
echo "***********james server done **********"


#Postfix smtp
echo "Installing postfix smtp server"
sudo apt update
sudo apt install postfix
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bk
echo "***smtp done***"

#Install ssh server
sudo apt -y install openssh-server
sudo systemctl enable --now ssh
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-arm64"
export PATH=$PATH:$JAVA_HOME/bin
sudo systemctl restart smbd
