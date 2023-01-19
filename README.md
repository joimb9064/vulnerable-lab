# This script creates a vulnerable lab for network pentest training
#!/bin/bash
# Install smtp
sudo apt update
# Samba
echo "*********Install samba*********"
sudo apt install samba -y
sudo mkdir -p /samba
sudo ufw allow samba
echo "*******samba done**********"
# install docker
echo "***********Install docker***********"
sudo apt update
sudo apt install ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt update
  sudo chmod a+r /etc/apt/keyrings/docker.gpg -y
sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo usermod -aG docker ${USER}
echo "*********docker is done**********"
# Install vulnerable james server
echo "*********install james server********"
sudo apt install bash-completion  
curl -O https://archive.apache.org/dist/james/server/apache-james-2.3.2.tar.gz
tar -xzf apache-james-2.3.2.tar.gz
sudo cp -r james-2.3.2 /opt
sudo chmod +x /opt/james-2.3.2/bin/*.sh
curl -O https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-i586.tar.gz  
tar -xf jdk-8u202-linux-i586.tar.gz 
sudo mv jdk1.8.0_202 /opt/james-2.3.2/bin/
echo "***********james server done **********"
# Tomcat
echo "********About to install apache tomcat***"
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.71/bin/apache-tomcat-9.0.71.tar.gz
tar -xf apache-tomcat-9.0.71.tar.gz
sudo mv apache-tomcat-9.0.71 /opt
echo "apache tomcat is done"
# Log4j PoC
echo "*********log4j poc************"
mkdir ~/mylog4j
git clone https://github.com/kozmer/log4j-shell-poc.git
sudo mv log4j-shell-poc ~/mylog4j
curl -O https://repo.huaweicloud.com/java/jdk/8u202-b08/jdk-8u202-linux-i586.tar.gz  
tar -xf jdk-8u202-linux-i586.tar.gz 
mv  jdk1.8.0_202  jdk1.8.0_20
sudo mv jdk1.8.0_20 ~/mylog4j/log4j-shell-poc
cd ~/mylog4j/log4j-shell-poc
sudo apt install python3-pip
pip install -r requirements.txt
echo "*******log4j poc done*******"
