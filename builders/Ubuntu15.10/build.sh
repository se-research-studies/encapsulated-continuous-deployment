#!/bin/bash

cd /opt/OpenDaVINCI && \
    rm -fr build.ubuntu_wily && \
    mkdir build.ubuntu_wily && \
    cd build.ubuntu_wily && \
    cmake -D CMAKE_INSTALL_PREFIX=unused .. && \
    make && \
    cd .. && \
    chown -R 1000:1000 *
