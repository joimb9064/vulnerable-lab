
#Install java 8
#!/bin/bash
sudo apt update 
sudo apt install openjdk-8-jdk -y
#Samba
echo "*********Install samba*********"
sudo apt -y install samba 
sudo mkdir -p /samba
sudo mkdir -p /samba/alice
sudo mkdir -p /samba/josh
sudo mkdir -p /samba/james
sudo mkdir -p /home/share
sudo chmod 777 /home/share
sudo ufw allow samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bk
sudo cp smb.conf /etc/samba/
sudo cp private.key /samba/alice
sudo cp private.key /samba/josh
echo "*******samba done**********"
#install ncat
sudo apt install ncat -y
echo "***********ncat is don**********"
#install docker
echo "***********Install docker***********"

# Add Docker's official GPG key:
sudo apt update
sudo apt -y install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
#  sudo apt -y install docker.io docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
#curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
#sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update
sudo apt -y install docker.io
sudo usermod -aG docker ${USER}
sudo apt -y install docker-compose 
echo "*********docker is done**********"

#install james server
echo "*********install james server********"
sudo apt -y install bash-completion  
curl -O https://archive.apache.org/dist/james/server/apache-james-2.3.2.tar.gz
tar -xzf apache-james-2.3.2.tar.gz
sudo cp -r james-2.3.2 /opt
sudo cp phoenix.sh /opt/james-2.3.2/bin/
sudo chmod +x /opt/james-2.3.2/bin/*.sh
sudo cp  /opt/james-2.3.2/apps/james/SAR-INF/config.xml  /opt/james-2.3.2/apps/james/SAR-INF/config.xml.bk
echo "***********james server done **********"

#Install ssh server
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
sudo apt -y install net-tools

export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-arm64"
export PATH=$PATH:$JAVA_HOME/bin
sudo systemctl restart smbd

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

#Tomcat
echo "********About to install apache tomcat***"
sudo apt install default-jdk -y
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.17/bin/apache-tomcat-10.1.17.tar.gz
tar -xvzf apache-tomcat-10.1.17.tar.gz
#sudo mv apache-tomcat-10.1.17 /opt
exit
cd ~/vulnerable-lab/

cp server.xml tomcat-users.xml tomcat-users.xm apache-tomcat-10.1.17/conf
cp apache-tomcat-10.1.17/webapps/host-manager/META-INF/context.xml apache-tomcat-10.1.17/webapps/host-manager/META-INF/context.xml.bk
cp context.xml apache-tomcat-10.1.17/webapps/host-manager/META-INF/context.xml 
sudo mv apache-tomcat-10.1.17 /opt
sudo cp config.xml /opt/james-2.3.2/apps/james/SAR-INF/
sudo cp james-fetchmail.xml /opt/james-2.3.2/apps/james/conf/


echo "----------------apache tomcat installation  done---------------"

