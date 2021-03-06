#!/bin/bash

sudo apt-get -y -qq install git
sudo apt-get -y -qq install libtool autoconf pkg-config libpcre3-dev libyaml-dev
sudo apt-get -y -qq install zlib1g-dev
sudo apt-get -y -qq install libpcap-dev
sudo apt-get -y -qq install libnet-dev
sudo apt-get -y -qq install libmagic-dev
sudo apt-get -y -qq install libjansson-dev

cd /tmp

#luajit
wget http://luajit.org/download/LuaJIT-2.0.3.tar.gz
tar -xzf LuaJIT-2.0.3.tar.gz 
cd LuaJIT-2.0.3/
make
sudo make install
sudo ldconfig
cd ..
rm -rf LuaJIT-2.0.3 

# libhtp
git clone https://github.com/ironbee/libhtp.git -b 0.5.x
cd libhtp
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
cd ..
rm -rf libhtp

#suricata
git clone git://phalanx.openinfosecfoundation.org/oisf.git
cd oisf
./autogen.sh
./configure --enable-luajit --enable-non-bundled-htp
make
sudo make install-full
sudo suricata -T --disable-detection
sudo suricata --list-app-layer-protos 

cd ..
rm -rf oisf

cd /home/vagrant
mkdir log
wget -q http://malware-traffic-analysis.net/2014/10/09/UpdateFlashPlayer_811e7dfc.exe-malwr.com-analysis.pcap
suricata -r UpdateFlashPlayer_811e7dfc.exe-malwr.com-analysis.pcap -l log 

#put template to elastic
wget -q https://raw.githubusercontent.com/hillar/vagrant_moloch_bro_suricata/master/elastic_template_suricata.json
curl -XPUT http://192.168.33.111:9200/_template/suricata -d@elastic_template_suricata.json
npm install byline
wget https://gist.githubusercontent.com/hillar/4b014ba3abcc07a8c5c9/raw/364e6bfcab31ea914b4aaf3a5244ee5520dee4c6/json2elastic.js
node json2elastic.js log/eve.json 192.168.33.111:9200/suri-1/event

