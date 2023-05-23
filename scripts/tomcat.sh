#!/bin/bash
sudo yum update -y 
sudo yum install telnet nc net-tools httpd -y 
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
sudo yum install java -y 
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.8/bin/apache-tomcat-10.1.8-windows-x64.zip
unzip apache-tomcat-10.1.8-windows-x64.zip
rm -rf apache-tomcat-10.1.8-windows-x64.zip
cd apache-tomcat-10.1.8/bin/
chmod 755 *.sh
sh startup.sh