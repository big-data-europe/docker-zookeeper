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
 * Docker Image directory structure and files
  * /app (symlink to : /usr/local/apache-zookeeper/zookeeper-3.5.2-alpha)
  * /config (symlink to : /usr/local/apache-zookeeper/zookeeper-3.5.2-alpha/conf)
  * /app/bin/zk-config (=/usr/local/apache-zookeeper/zookeeper-3.5.2-alpha/bin/zk-config, see below)
 * Apache Zookeeper requires a myid file containing a number between 1 and 255. The myid file specifies a single unique id of a zookeeper quorum's server. To be able to run zookeeper using an orchestration framework it is required to have knowledge about the planned quorum so that myid files can be created on the fly. This docker image includes a bash script that reads Apache Zookeeper's zoo.cfg file and creates myid files in case they do not exist. 
 * As of version 3.5.0 Apache Zookeeper makes use of a dynamic configuration file for members of the quorum. This file needs to be linked (by absolute file path) from the central zoo.cfg.
 * It is highly recommended to map directories to make zookeeper data persistent but it is not strictly required.
 * This docker image has one strict required when applying the below workflow for running zookeeper on the BDE platform: The IPs or hostnames used in quorum config file must be recognizeable by linux shell commands: hostname or hostname -I, the zk-config script is using these commands to find the matching entry in the config to set myid correctly. see below for an example.
 
To run this Zookeeper Docker with the BDE platform

* This example assumes that data directories are not mapped on the host system.
* This example assumes that the zookeeper quorum uses the following three servers
  * bde-one.example.com
  * bde-two.example.com
  * bde-three.example.com
* Extend this docker image adding suitable zoo.cfg and zoo_replicated1.cfg.dynamic files to /config directory
  * Dockerfile
  ```bash
  FROM bde2020/zookeeper
  ADD zoo.cfg /config/
  ADD zoo_replicated1.cfg.dynamic
  ```
  * zoo.cfg
  ```bash
  standaloneEnabled=false
  dataDir=/tmp/zookeeper
  syncLimit=2
  initLimit=5
  tickTime=2000
  dynamicConfigFile=/config/zoo_replicated1.cfg.dynamic
  ```
  * zoo_replicated1.cfg.dynamic
  ```bash
  server.1=bde-one.example.com:31200:31201:participant;31202
  server.2=bde-two.example.com:31200:31201:participant;31202
  server.3=bde-three.example.com:31200:31201:participant;31202
  ```
  * Start the image with
  ```bash
  cd /app/bin && ./zk-config && zkServer.sh start-foreground
  ```
* The following example is taken from SC6 (the full example can be found here: https://github.com/big-data-europe/pilot-sc6-cycle2)
  * Docker extension (built as your/zookeeper)
  ```bash
  FROM bde2020/zookeeper:latest
  ADD zoo.cfg /config/
  ADD zoo_replicated1.cfg.dynamic /config/  
  ```
  * zoo.cfg (containing a reference to the dynamic zookeeper configuration file)
  ```bash
  standaloneEnabled=false
  dataDir=/tmp/zookeeper
  syncLimit=2
  initLimit=5
  tickTime=2000
  dynamicConfigFile=/config/zoo_replicated1.cfg.dynamic
  ```
  * zoo_replicated1.cfg.dynamic (containing the zookeeper nodes, note that we define the hostnames in the docker-compose.yml)
  ```bash
  server.1=sc6_zoo_1:31200:31201:participant;31202
  server.2=sc6_zoo_2:31200:31201:participant;31202
  server.3=sc6_zoo_3:31200:31201:participant;31202  
  ```
  * docker-compose.yml (the docker image's startup script will determine it's own ip/hostname and try to find itself in zoo_replicated1.cfg.dynamic. from the line in the configuration the myid is then determined and written to zookeeper's config directory)
  ```bash
  services:
    sc6_zoo_1:
      image: "bde2020/sc6-zookeeper"
      ports: 
        - 31200:31200
        - 31201:31201
        - 31202:31202
      container_name: sc6_zoo_1
      command: "bash -c /startup"
      hostname: "sc6_zoo_1"
      environment:
        - "constraint:node==host-one.your-cluster.net"
    sc6_zoo_2:
      image: "bde2020/sc6-zookeeper"
      ports:
        - 31200:31200
        - 31201:31201
        - 31202:31202
      container_name: sc6_zoo_2
      command: "bash -c /startup"
      hostname: "sc6_zoo_2"
      environment:
        - "constraint:node==host-two.your-cluster.net"
   ....
  ```
