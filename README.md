<!--
########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2026 kokoroq. All rights reserved.
#
#
#                       README - English                      
#
#
#
#                                               VERSION: 1.0
########################################################################
-->

# MCSOC     : A management tool of Minecraft server for Container

**MCSOC** is a command line tool that manages a Minecraft server (Bedrock and Java) running on a container base.

- **Multi Servers** : Multiple Minecraft servers can run simultaneously on a single instance
- **Easy Management** : Create and delete servers, check status, etc. with a single command
- **Simple Backup** : Automatic or Manual backup. Of course, servers can also be restored
<br>

# Support Minecraft version
- 26.X
- 1.21.X

# Requirement

### Operating System
- Linux
    - The list is confirmed OS
        - Ubuntu 22.04
        - Ubuntu 24.04
        - Ubuntu 26.04

### Packages :
- Docker
- unzip
- wget
- cron
- SQLite

[Docker](https://www.docker.com/) must be installed before running the MCSOC installation script.
> [IMPORTANT!]
> Recommend to install from Docker official repository.
<br>

# Installation

- Use `apt` to install MCSOC.<br>
Before installing the package, please make sure Docker is installed.

```bash
apt update
apt install ./mcsoc_X.X.X-1_all.deb
```
<br>

# Usage

Services are provided through `mcsoc` command.<br><br>

- To create a Minecraft server, run the `mcsoc create` command and follow the instructions on the display.<br>
When running the command, add the absolute path to the **Minecraft server application** or **the backup data** created by MCSOC Backup service.<br>

e.g. If you are creating Java Edition
```bash:
mcsoc create java /tmp/server.jar
```
<br>

e.g. If you are creating Bedrock Edition
```bash:
mcsoc create be /tmp/bedrock-server-X.XX.XX.XX.zip
```
<br>

- To start the created server, use the `mcsoc start` command with the container name.
```bash:
mcsoc start my_server
```
<br>

- To stop the running server, use the `mcsoc stop` command with the container name.
```bash:
mcsoc stop my_server
```
<br>

- To delete the created server, use the `mcsoc rm` command with the container name.
```bash:
mcsoc rm my_server
```
<br>

### Function

- To run Minecraft commands on the server, use the `mcsoc com` command.
```bash:
mcsoc com my_server "say HELLO!"
```
<br>

### Backup

- There are two ways to backup by MCSOC.
    - **FULL**: Backup all data on the server. During backup, the server is stopped.
    - **INSTANT**: Backup minimal data on the server. During backup, the server is not stopped.
        - Backup data supported by `mcsoc create` is only for **FULL**.

<br>

- To backup manually, use the `mcsoc backup` command.
```bash:
mcsoc backup full my_server
```

<br>

- You can also set up scheduled backup when you create the server. Backup will begin by the following rules according to the number of servers<br>
    - **FULL**:  Once a week / One run between 6:00 and 7:00 am.
    - **INSTANT**: Everyday / One run between 3:00 and 5:50 am.
<br>

### Status
- To check the status of MCSOC, use the `mcsoc -s` command.
```bash:
mcsoc -s
```
- To see detailed information about the server you have created, use the `mcsoc info` command.
```bash:
mcsoc info
```

### Help
- For more information on the `mcsoc` command, check the help.
```bash:
mcsoc -h
```
<br>

# Upgrade

- To upgrade the MCSOC version, use `dpkg`

```bash
dpkg -i ./mcsoc_X.X.X-1_all.deb
```
<br>

# Uninstallation

- To uninstall MCSOC, use `apt`.

```bash
apt purge mcsoc
```

# Language

 **[Japanese - 日本語](./docs/README_ja.md)**

# Support

Contact: kokoroq

# License

MCSOC is distributed under `BSD License`. See [LICENSE](./LICENSE)
