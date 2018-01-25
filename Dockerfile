FROM ubuntu:16.04

## General package configuration
RUN apt-get -y update && \
    apt-get -y install \
        sudo \
        unzip \
        curl \
        xmlstarlet \
        git \
        netcat-traditional \
        software-properties-common \
        debconf-utils \
        uuid-runtime \
        ncurses-bin \
        iputils-ping \
        zip \
        vim \
        make \
        fakeroot \
        apt-transport-https


## Install Oracle JVM
RUN \
  echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer


## RUNDECK setup env

ENV USERNAME=rundeck \
    USER=rundeck \
    HOME=/home/rundeck \
    LOGNAME=$USERNAME \
    TERM=xterm-256color \
    JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    PATH=$PATH:$JAVA_HOME/bin

# RUNDECK - create user
RUN adduser --shell /bin/bash --home $HOME --gecos "" --disabled-password $USERNAME && \
    passwd -d $USERNAME && \
    addgroup $USERNAME sudo && \
    git clone https://github.com/rundeck/rundeck.git /home/rundeck/rundeck

#RUNDECK build
RUN cd /home/rundeck/rundeck && ./gradlew build
VOLUME $HOME/rundeck   
WORKDIR $HOME/runde\ck


#I had problems with the .jar and .war files that were generated with the compilation of the app, 
#so I take the route to create a .deb package and install it inside the container

RUN cd packaging && \
    make deb && \
    dpkg -i rundeck*.deb && \
    cd .. && rm -rf  /home/rundeck/rundeck/* 

EXPOSE 4440
#Start Rundeck
ENTRYPOINT service rundeckd start && bash
