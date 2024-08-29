##################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                 Dockerfile for Bedrock Edition
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
#   PACKAGE:    tmux & tzdata & libcurl4
#   COPY:       Minecraft Server in app dir
#----------------------------------------------------------------#

# Base image
FROM ubuntu:22.04

# Dependent package
RUN apt-get update; \
    apt-get install -y tmux tzdata libcurl4; \
    ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime; \
    mkdir /tmp/mcsoc_install/;

# Copy files
COPY ./mcsv/app/* /tmp/mcsoc_install/

# Environment
ENV LANG=C.UTF-8
ENV SET_USERNAME=

# Initialize
RUN mkdir -p /opt/minecraft/be/; \
    cp -rT /tmp/mcsoc_install/ /opt/minecraft/be/; \
    rm -rf /tmp/mcsoc_install/; \
    useradd ${SET_USERNAME}; 

# Work directory
WORKDIR /opt/minecraft/be/