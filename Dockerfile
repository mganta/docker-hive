FROM ubuntu:latest

# update and install basic tools
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -yq curl software-properties-common


# install java
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle


# install hadoop
RUN mkdir /usr/local/hadoop
RUN curl -s http://apache.claz.org/hadoop/common/hadoop-2.7.2/hadoop-2.7.2.tar.gz | tar -xz -C /usr/local/hadoop --strip-components 1
ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_INSTALL $HADOOP_HOME
ENV PATH $PATH:$HADOOP_INSTALL/sbin
ENV HADOOP_MAPRED_HOME $HADOOP_INSTALL
ENV HADOOP_COMMON_HOME $HADOOP_INSTALL
ENV HADOOP_HDFS_HOME $HADOOP_INSTALL
ENV YARN_HOME $HADOOP_INSTALL
ENV PATH $HADOOP_HOME/bin:$PATH


# install hive
RUN mkdir /usr/local/hive
RUN curl -s http://www-eu.apache.org/dist/hive/hive-2.1.1/apache-hive-2.1.1-bin.tar.gz | tar -xz -C /usr/local/hive --strip-components 1
ENV HIVE_HOME /usr/local/hive
ENV PATH $HIVE_HOME/bin:$PATH

COPY sqljdbc42.jar /usr/local/hive/lib/
COPY azure-data-lake-store-sdk.jar /usr/local/hive/lib/
COPY hadoop-azure.jar /usr/local/hive/lib/
COPY azure-storage-4.2.0.jar /usr/local/hive/lib/
COPY hadoop-azure-datalake.jar /usr/local/hive/lib/

CMD /usr/local/hive/bin/hive --service metastore $DB_URL $DB_USER $DB_PASSWORD
