#!/bin/bash
sudo apt install -y gpg
sudo curl https://s3.amazonaws.com/amazon-ssm-eu-west-1/latest/debian_amd64/amazon-ssm-agent.deb.sig -o /tmp/amazon-ssm-agent.deb.sig
sudo gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 9C6D6DDEA2612D3F
gpg --verify /tmp/amazon-ssm-agent.deb.sig /tmp/amazon-ssm-agent.deb
sudo curl https://s3.amazonaws.com/amazon-ssm-eu-west-1/latest/debian_amd64/amazon-ssm-agent.deb -o /tmp/amazon-ssm-agent.deb
sudo dpkg -i /tmp/amazon-ssm-agent.deb
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent
#installing Elasticsearch
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt-get install apt-transport-https
echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
sudo apt-get update
sudo apt-get install elasticsearch
sudo sed -i 's/## -Xms4g/-Xms1g/g' /etc/elasticsearch/jvm.options
sudo sed -i 's/## -Xmx4g/-Xmx1g/g' /etc/elasticsearch/jvm.options
sudo systemctl start elasticsearch.service
sudo systemctl enable elasticsearch.service
#installing Kibana
sudo apt-get install kibana
sudo systemctl start kibana.service
sudo systemctl enable kibana.service
sudo sed -i 's/#server.host: "localhost"/server.host: "0.0.0.0"/g' /etc/kibana/kibana.yml
sudo systemctl restart kibana.service
sudo sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/#discovery.seed_hosts:/discovery.seed_hosts:/g' /etc/elasticsearch/elasticsearch.yml
sed -i 's/"host1", "host2"/"127.0.0.1"/g' /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch.service