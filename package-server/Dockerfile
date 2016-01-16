# Author: Christian Berger
# Date: 2015-04-22

FROM ubuntu:14.04
MAINTAINER Christian Berger "christian.berger@gu.se"

# Set the env variable DEBIAN_FRONTEND to noninteractive.
ENV DEBIAN_FRONTEND noninteractive

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

# Installing the required environment to serve packages.
RUN apt-get -y install nginx reprepro createrepo expect

RUN apt-get clean
RUN apt-get autoremove

# Set locale (fix the locale warnings)
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# Copy nginx configuration.
ADD nginx.configuration /etc/nginx/sites-available/default

# Copy keys for signing packages.
ADD keys/pubring.gpg /pubring.gpg
ADD keys/secring.gpg /secring.gpg
ADD keys/RPM-GPG-KEY-developer /RPM-GPG-KEY-developer
ADD signrpm.exp /signrpm.exp

# Copy binary packages.
ADD packages/deb/* /tmp/
ADD packages/rpm/* /tmp/

# Copy packages from encapsulated builders.
RUN mkdir -p /packages/ubuntu_wily
ADD packages.ubuntu_wily/deb/* /packages/ubuntu_wily/
ADD packages.ubuntu_wily/rpm/* /packages/ubuntu_wily/

# Copy setup script.
ADD setup.sh /setup.sh

# Copy static website.
RUN mkdir -p /var/reprepro/www
ADD www /var/reprepro/www

# Copy API documentation.
RUN mkdir -p /var/reprepro/api
ADD api /var/reprepro/api

# Run setup script to prepare the environment.
RUN chmod 700 setup.sh
RUN ./setup.sh

# Enable access to port 80.
EXPOSE 80
CMD ["nginx"]
