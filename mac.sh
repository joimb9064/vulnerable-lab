#Install java 8
#!/bin/bash
sudo apt update 
sudo apt -y install openjdk-8-jdk 
#Samba
echo "*********Install samba*********"
sudo apt -y install samba
sudo mkdir -p /samba
sudo mkdir -p /samba/alice
sudo mkdir -p /samba/josh
sudo mkdir -p /samba/james
sudo cp private.key /samba/alice
sudo cp private.key /samba/josh
sudo ufw allow samba
echo "*******samba done**********"

#install docker
echo "***********Install docker***********"
sudo apt update
sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
sudo apt -y install docker.io 
sudo usermod -aG docker ${USER}
echo "*********docker is done**********"

#install james server
echo "*********install james server********"
sudo apt -y install bash-completion  
curl -O https://archive.apache.org/dist/james/server/apache-james-2.3.2.tar.gz
tar -xzf apache-james-2.3.2.tar.gz
sudo cp -r james-2.3.2 /opt
sudo cp phoenix.sh /opt/james-2.3.3/bin/
sudo chmod +x /opt/james-2.3.2/bin/*.sh
echo "----------james server installation done ---------------"

#Tomcat
echo "********About to install apache tomcat***"
curl -O https://dlcdn.apache.org/tomcat/tomcat-10/v10.0.27/bin/apache-tomcat-10.0.27.tar.gz
tar -xf apache-tomcat-10.0.27.tar.gz
cp server.xml tomcat-users.xml apache-tomcat-10.0.27/conf
cp manager.xml apache-tomcat-10.0.27/conf/Catalina/localhost/
sudo mv apache-tomcat-10.0.27 /opt
echo "----------------apache tomcat installation  done---------------"

#Log4j PoC
echo "*********log4j poc************"
mkdir ~/mylog4j
git clone https://github.com/kozmer/log4j-shell-poc.git
sudo mv log4j-shell-poc ~/mylog4j  
cp poc.py ~/mylog4j/log4j-shell-poc/
cd ~/mylog4j/log4j-shell-poc
sudo apt install python3-pip
pip install -r requirements.txt

echo "----------log4j poc installation done----------"

#Install ssh server
echo "***********SSH*******************"
sudo apt -y install openssh-server
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bk 
chmod 644 sshd_config
sudo cp sshd_config /etc/ssh/
sudo cp private.key ~/.ssh/
sudo cp public.pub ~/.ssh/
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat public.pub >> ~/.ssh/authorized_keys
sudo systemctl enable --now ssh
#crontab
sudo cp /etc/crontab /etc/crontab.bk
chmod 644 crontab
sudo cp crontab /etc/

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-arm64"
export PATH=$PATH:$JAVA_HOME/bin
