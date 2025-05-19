#!/bin/bash
# Hadoop Installation Script for Ubuntu
# Author: Rahmatullah Zadran

# Step 1: Install Java
sudo apt update && sudo apt install -y openjdk-8-jdk

# Step 2: Verify Java Installation
java -version

# Step 3: Install SSH
sudo apt install -y ssh

# Step 4: Create Hadoop User
sudo adduser hadoop

# Step 5: Switch to Hadoop User
su - hadoop <<'EOF'

# Step 6: Configure SSH
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 640 ~/.ssh/authorized_keysssh -o StrictHostKeyChecking=no localhost

# Step 7: Download and Extract Hadoop
wget https://dlcdn.apache.org/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
tar -xvzf hadoop-3.3.6.tar.gz
mv hadoop-3.3.6 hadoop

# Step 8: Set Environment Variables
echo 'export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64' >> ~/.bashrc
echo 'export HADOOP_HOME=/home/hadoop/hadoop' >> ~/.bashrc
echo 'export HADOOP_INSTALL=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_MAPRED_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_HDFS_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_YARN_HOME=$HADOOP_HOME' >> ~/.bashrc
echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native' >> ~/.bashrc
echo 'export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin' >> ~/.bashrc
echo 'export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"' >> ~/.bashrc
source ~/.bashrc

# Step 9: Update JAVA_HOME in hadoop-env.sh
sed -i "s|^export JAVA_HOME=.*|export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64|"
$HADOOP_HOME/etc/hadoop/hadoop-env.sh

# Step 10: Create Hadoop Data Directories
mkdir -p ~/hadoopdata/hdfs/{namenode,datanode}

# Step 11: Configure Hadoop core-site.xml
cat > $HADOOP_HOME/etc/hadoop/core-site.xml << EOL
<configuration>
<property>
<name>fs.defaultFS</name>
<value>hdfs://localhost:9000</value>
</property>
</configuration>
EOL

# Step 12: Configure hdfs-site.xml
cat > $HADOOP_HOME/etc/hadoop/hdfs-site.xml << EOL
<configuration>
<property>
<name>dfs.replication</name>
<value>1</value>
</property>
<property>
<name>dfs.namenode.name.dir</name>
<value>file:///home/hadoop/hadoopdata/hdfs/namenode</value>
</property>
<property>
<name>dfs.datanode.data.dir</name>
<value>file:///home/hadoop/hadoopdata/hdfs/datanode</value>
</property>
</configuration>
EOL

# Step 13: Configure mapred-site.xml
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template
$HADOOP_HOME/etc/hadoop/mapred-site.xml
cat > $HADOOP_HOME/etc/hadoop/mapred-site.xml << EOL
<configuration>
<property>
<name>mapreduce.framework.name</name>
<value>yarn</value>
</property>
</configuration>
EOL

# Step 14: Configure yarn-site.xml
cat > $HADOOP_HOME/etc/hadoop/yarn-site.xml << EOL
<configuration>
<property>
<name>yarn.nodemanager.aux-services</name>
<value>mapreduce_shuffle</value>
</property>
</configuration>
EOL

# Step 15: Format NameNode
hdfs namenode -format

# Step 16: Start Hadoop Servicesstart-all.sh
start-all.sh
# Step 17: Verify Services
jps

# Step 18: Create HDFS directories for testing
hdfs dfs -mkdir /testing
hdfs dfs -mkdir /logs
hdfs dfs -put /var/log/* /logs/
hdfs dfs -ls /
EOF
# Done
