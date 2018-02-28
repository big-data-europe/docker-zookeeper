FROM java:8

MAINTAINER Juergen Jakobitsch <jakobitschj@semantic-web.at>

# Install utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y netcat

# Zookeeper version to be used
ENV ZK_VERSION zookeeper-3.4.11

# Download distribution
RUN wget -q http://ftp.halifax.rwth-aachen.de/apache/zookeeper/"$ZK_VERSION"/"$ZK_VERSION".tar.gz -O /tmp/"$ZK_VERSION".tar.gz \
    && tar xfz /tmp/"$ZK_VERSION".tar.gz -C /opt \
    && rm /tmp/"$ZK_VERSION".tar.gz

# The common installation dirname to use zookeeper
RUN ln -s /opt/"$ZK_VERSION" /opt/zookeeper

# Define the run configuration
RUN cd /opt/zookeeper/conf \
    && cp -p zoo_sample.cfg zoo.cfg

EXPOSE 2181

COPY wait-for-step.sh /
COPY execute-step.sh /
COPY finish-step.sh /

COPY healthcheck /
COPY zookeeper-startup.sh /

CMD [ "./zookeeper-startup.sh" ]
