# Install Java 8
PREFIX="JAVA Default JDK Provisioner:"
set -e

# For installing Java 8
apt-get -y update
apt-get -y install default-jdk

if $(test -e /usr/lib/libjvm.so); then
  rm /usr/lib/libjvm.so
fi

ln -s /usr/lib/jvm/default-java/jre/lib/amd64/server/libjvm.so /usr/lib/libjvm.so

# Install Mesos
PREFIX="Mesos Provisioner: "
set -e

echo "${PREFIX} Installing pre-reqs..."
# For Mesos
apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
apt-get -y update

apt-get -y install libcurl3
apt-get -y install zookeeperd
apt-get -y install aria2
apt-get -y install ssh
apt-get -y install rsync

apt-get -y install mesos=0.24.1-0.2.35.ubuntu1404

# Install docker
set -e

#Install docker
echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list
apt-get update
apt-get -y install docker.io

# Install Hadoop
# TODO: Cloudera Distribution for Hadoop instead of Apache Hadoop
# $1 is HADOOP_VERSION
set -e

apt-get update

apt-get install -y openssh-server
apt-get install -y tar
apt-get install -y gzip

# Add hduser user and hadoop group

if [ `/bin/egrep  -i "^hadoop:" /etc/group` ]; then
   echo "Group hadoop already exists"
else
  echo "Adding hadoop group"
  addgroup hadoop
fi


if [ `/bin/egrep  -i "^hduser:" /etc/passwd` ]; then
  echo "User hduser already exists"
else
  echo "creating hduser in group hadoop"
  adduser --ingroup hadoop --disabled-password --gecos "" --home /home/hduser hduser
  adduser hduser sudo
fi

# Setup password-less auth
sudo -u hduser sh -c "mkdir -p /home/hduser/.ssh"
sudo -u hduser sh -c "chmod 700 /home/hduser/.ssh"
sudo -u hduser sh -c "yes | ssh-keygen -t rsa -N '' -f /home/hduser/.ssh/id_rsa"
sudo -u hduser sh -c 'cat /home/hduser/.ssh/id_rsa.pub >> /home/hduser/.ssh/authorized_keys'
#sudo -u hduser sh -c "ssh-keyscan -H $1 >> /home/hduser/.ssh/known_hosts"
sudo -u hduser sh -c "ssh-keyscan -H localhost >> /home/hduser/.ssh/known_hosts"
#sudo -u hduser sh -c "ssh-keyscan -H $2 >> /home/hduser/.ssh/known_hosts"

# Download Hadoop
HADOOP_VER="2.7.0"
cd ~
if [ ! -f /tmp/hadoop-${HADOOP_VER}.tar.gz ]; then
	wget http://apache.osuosl.org/hadoop/common/hadoop-${HADOOP_VER}/hadoop-${HADOOP_VER}.tar.gz -O /tmp/hadoop-${HADOOP_VER}.tar.gz
fi

sudo tar ixzf /tmp/hadoop-${HADOOP_VER}.tar.gz -C /usr/local
cd /usr/local
rm -rf hadoop
sudo mv -f hadoop-${HADOOP_VER} hadoop
sudo chown -R hduser:hadoop hadoop

# Init bashrc with hadoop env variables
sudo sh -c 'echo export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_INSTALL=/usr/local/hadoop >> /home/hduser/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> /home/hduser/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export YARN_HOME=\$HADOOP_INSTALL >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native >> /home/hduser/.bashrc'
sudo sh -c 'echo export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\" >> /home/hduser/.bashrc'
# hit the ubuntu user with the same thing
sudo sh -c 'echo export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64 >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_INSTALL=/usr/local/hadoop >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/bin >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export PATH=\$PATH:\$HADOOP_INSTALL/sbin >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_MAPRED_HOME=\$HADOOP_INSTALL >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_HOME=\$HADOOP_INSTALL >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_HDFS_HOME=\$HADOOP_INSTALL >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export YARN_HOME=\$HADOOP_INSTALL >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_COMMON_LIB_NATIVE_DIR=\$\{HADOOP_INSTALL\}/lib/native >> /home/ubuntu/.bashrc'
sudo sh -c 'echo export HADOOP_OPTS=\"-Djava.library.path=\$HADOOP_INSTALL/lib\" >> /home/ubuntu/.bashrc'


# Modify JAVA_HOME in hadoop-env
cd /usr/local/hadoop/etc/hadoop
sudo -u hduser sed -i.bak s=\${JAVA_HOME}=//usr/lib/jvm/java-7-openjdk-amd64/=g hadoop-env.sh
pwd

/usr/local/hadoop/bin/hadoop version

# Update configuration
#sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://localhost:9000\</value>\</property>=g' core-site.xml
#sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>fs\.default\.name\</name>\<value>hdfs://'"$1"':9000\</value>\</property>=g' core-site.xml
#sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>yarn\.nodemanager\.aux-services</name>\<value>mapreduce_shuffle</value>\</property>\<property>\<name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\<value>org\.apache\.hadoop\.mapred\.ShuffleHandler</value>\</property>=g' yarn-site.xml

#sudo -u hduser cp mapred-site.xml.template mapred-site.xml
#sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>mapreduce\.framework\.name</name>\<value>yarn</value>\</property>=g' mapred-site.xml

#cd ~
#sudo -u hduser sh -c 'mkdir -p ~hduser/mydata/hdfs/namenode'
#sudo -u hduser sh -c 'mkdir -p ~hduser/mydata/hdfs/datanode'
#sudo chown -R hduser:hadoop ~hduser/mydata

#cd /usr/local/hadoop/etc/hadoop
#sudo -u hduser sed -i.bak 's=<configuration>=<configuration>\<property>\<name>dfs\.replication</name>\<value>1\</value>\</property>\<property>\<name>dfs\.namenode\.name\.dir</name>\<value>file:/home/hduser/mydata/hdfs/namenode</value>\</property>\<property>\<name>dfs\.datanode\.data\.dir</name>\<value>file:/home/hduser/mydata/hdfs/datanode</value>\</property>\<property>\<name>dfs\.namenode\.datanode\.registration\.ip-hostname-check</name>\<value>false</value>\</property>=g' hdfs-site.xml
