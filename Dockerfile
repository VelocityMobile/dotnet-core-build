FROM ubuntu:16.04

# Dependencies
RUN apt-get update
RUN apt-get install -y curl apt-transport-https

# Dotnet Core 1.1
RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ xenial main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893

RUN apt-get update
RUN apt-get install -y dotnet-dev-1.0.4

# MSSQL tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | tee /etc/apt/sources.list.d/msprod.list

ENV DEBIAN_FRONTEND=noninteractive
ENV ACCEPT_EULA=Y

RUN apt-get update
RUN apt-get install -y mssql-tools unixodbc-dev

RUN ln -sfn /opt/mssql-tools/bin/sqlcmd /usr/bin/sqlcmd
RUN ln -sfn /opt/mssql-tools/bin/bcp /usr/bin/bcp

# Trigger the population of the local package cache
ENV NUGET_XMLDOC_MODE skip
RUN mkdir warmup \
    && cd warmup \
    && dotnet new \
    && cd .. \
    && rm -rf warmup \
    && rm -rf /tmp/NuGetScratch

# Update locales
RUN apt-get install locales
RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN set -x && \
    VER="17.03.0-ce" && \
    curl -L -o /tmp/docker-$VER.tgz https://get.docker.com/builds/Linux/x86_64/docker-$VER.tgz && \
    tar -xz -C /tmp -f /tmp/docker-$VER.tgz && \
    mv /tmp/docker/* /usr/bin
