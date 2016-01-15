# Author: Christian Berger
# Date: 2016-01-13

FROM ubuntu:15.10
MAINTAINER Christian Berger "christian.berger@gu.se"

# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

# 0. We need wget to install our repository's key.
RUN apt-get -y install wget

# 1. Add the deb repository from our production server-under-test (assumed to be executed at port 7777).
RUN wget -O - -q http://opendavinci.cse.chalmers.se:7777/opendavinci.cse.chalmers.se.gpg.key | apt-key add -
RUN echo "deb http://opendavinci.cse.chalmers.se:7777/ubuntu-wily/ wily main" >> /etc/apt/sources.list

# 2. Update the package directory.
RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y

# 3. Installing the build environment.
RUN apt-get -y install build-essential 

# 4. Installing OpenDaVINCI library.
RUN apt-get -y install opendavinci-odlib opendavinci-odsupercomponent

# 5. Clean up the container.
RUN apt-get clean
RUN apt-get autoremove

# 6. Set locale (fix the locale warnings).
RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

# 7. The entire purpose for this container is to simply compile a small test program.
ADD compileRunTest.sh /compileRunTest.sh
CMD ["/compileRunTest.sh"]
