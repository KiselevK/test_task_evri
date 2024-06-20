#!/bin/bash
apt update -y && apt upgrade -y
apt install openjdk-21-jdk -y
apt install docker.io -y

usermod -a -G docker ubuntu


mkdir -p /home/ubuntu/jmeter

wget "https://dlcdn.apache.org//jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz"
tar -xvzf apache-jmeter-${JMETER_VERSION}.tgz --strip-components=1 -C /home/ubuntu/jmeter/
rm home/ubuntu/apache-jmeter-${JMETER_VERSION}.tgz

echo 'jmeter.save.saveservice.subresults=false' >> /home/ubuntu/jmeter/bin/user.properties

DNAME="CN=KK, OU=Test, O=Test, L=Kyiv, ST=Kyiv, C=UA"
keytool -genkey -keyalg RSA -alias rmi -keystore /home/ubuntu/jmeter/bin/rmi_keystore.jks -storepass changeit -validity 7 -keysize 2048 -dname "$DNAME"
echo 'export PATH="$PATH":/home/ubuntu/jmeter/bin' >> /home/ubuntu/.bashrc 

chown ubuntu:ubuntu -R /home/ubuntu/jmeter
chmod -R 775 jmeter

echo 'export PATH="$PATH":/home/ubuntu/jmeter/bin' >> /home/ubuntu/.bashrc 

echo "${private_server_key_pem}" > /home/ubuntu/.ssh/Test.pem
chown ubuntu:ubuntu /home/ubuntu/.ssh/Test.pem
chmod 400 /home/ubuntu/.ssh/Test.pem

