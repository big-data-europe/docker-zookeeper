# Zookeeper Docker

Versions used in this docker image:
* Zookeeper Version: 3.5.2-alpha
* Java 1.8.0_72
 
Image details:
* Installation directory: /app (i.e: /usr/local/apache-zookeeper/current)

## Zookeeper Docker image

To start the Zookeeper Docker image:

 ```bash
docker run -i -t bde2020/zookeeper /bin/bash
```
To build the Zookeeper Docker image:

 ```bash
git clone https://github.com/big-data-europe/docker-zookeeper.git
docker build -t bde2020/zookeeper .
```

Zookeeper image notes
 * Apache Zookeeper requires a myid file containing a number between 1 and 255. The myid file specifies a single unique id of a zookeeper quorum's server. To be able to run zookeeper using an orchestration framework it is required to have knowledge about the planned quorum so that myid files can be created on the fly. This docker image includes a bash script that reads Apache Zookeeper's zoo.cfg file and creates myid files in case they do not exist. 
 * As of version 3.5.0 Apache Zookeeper makes use of a dynamic configuration file for members of the quorum. This file needs to be linked (by absolute file path) from the central zoo.cfg.
