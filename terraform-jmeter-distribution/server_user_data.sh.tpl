#!/bin/bash
apt update -y && apt upgrade -y
apt install openjdk-21-jdk -y

cd /home/ubuntu

mkdir jmeter

wget "https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz"
tar -xvzf apache-jmeter-${JMETER_VERSION}.tgz --strip-components=1 -C jmeter
rm home/ubuntu/apache-jmeter-${JMETER_VERSION}.tgz
chmod -R 775 jmeter
chown ubuntu:ubuntu -R /home/ubuntu/jmeter

echo 'export PATH="$PATH":/home/ubuntu/jmeter/bin' >> ~/.bashrc 

