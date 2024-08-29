##################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                 Dockerfile for Java Edition
#
#
# This script is MCSOC Dockerfile
# PLEASE DO NOT EDIT
# Use with compose.yaml
#
#                                               VERSION: 1.0
##################################################################


#----------------------------------------------------------------#
#   BASE:       Ubuntu 22.04
#   PACKAGE:    OpenJDK 21 & tmux & tzdata
#   COPY:       Minecraft Server in app dir
#----------------------------------------------------------------#

# Base image
FROM ubuntu:22.04

# Dependent package
RUN apt-get update; \
    apt-get install -y openjdk-21-jre-headless tmux tzdata; \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime; \
    mkdir /tmp/mcsoc_install/;

# Copy files
COPY ./mcsv/app/. /tmp/mcsoc_install/

# Environment
ENV LANG=C.UTF-8
ENV SET_USERNAME=

# Initialize
RUN mkdir -p /opt/minecraft/java/; \
    cp -rT /tmp/mcsoc_install/ /opt/minecraft/java/; \
    rm -rf /tmp/mcsoc_install/; \
    useradd ${SET_USERNAME}; 

# Work directory
WORKDIR /opt/minecraft/java/