# Update configuration for HDFS 
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
