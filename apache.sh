
#!/bin/bash
sudo apt install default-jdk -y
#Tomcat
echo "********About to install apache tomcat***"
curl -O https://downloads.apache.org/tomcat/tomcat-10/v10.1.8/bin/apache-tomcat-10.1.8.tar.gz
tar -xvzf apache-tomcat-10.1.8.tar.gz
cp  apache-tomcat-10.1.8/conf/server.xml apache-tomcat-10.1.8/conf/server.xml.bk
cp apache-tomcat-10.1.8/conf/tomcat-users.xml apache-tomcat-10.1.8/conf/tomcat-users.xml.bk
cp server.xml tomcat-users.xml apache-tomcat-10.1.8/conf
cp apache-tomcat-10.1.8/webapps/host-manager/META-INF/context.xml apache-tomcat-10.1.8/webapps/host-manager/META-INF/contex>
cp context.xml apache-tomcat-10.1.8/webapps/host-manager/META-INF/context.xml 
sudo mv apache-tomcat-10.1.8 /opt
#dont for get to copy the manager file to /opt/apache-tomcat-10.1.8/Catalina/localhost after testing server
echo "----------------apache tomcat installation  done---------------"
