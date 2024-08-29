<!--
########################################################################
# Minecraft Complex Server Operator for Container (MCSOC)
#
# Copyright (c) 2023-2024 kokoroq. All rights reserved.
#
#
#                       README - Japanese                     
#
#
#
#                                               VERSION: 1.0
########################################################################
-->

# MCSOC     : A management tool of Minecraft server

**MCSOC**は、コンテナベースで実行されるMinecraftサーバー(Bedrock / Java)を管理するコマンドラインツールです。

- **マルチサーバー** : 1つのインスタンスで複数のMinecraftサーバーを同時に起動
- **容易な管理** : サーバーの作成、削除やステータスの確認などサーバーの管理面をコマンド一つで実行
- **バックアップ** : 自動もしくは手動で簡単バックアップ。サーバーのリストアもコマンドで可能
<br>

# Requirement

### OS (The list is confirmed)
- Linux
    - Ubuntu 22.04

### Packages :
- Docker
- unzip
- wget
- cron
- SQLite

[Docker](https://www.docker.com/)はMCSOCインストールスクリプトを実行する前にインストールしてください。
> [!IMPORTANT]
> Docker公式リポジトリからのインストールを推奨します。
<br>

# Installation

ダウンロードしたMCSOCのディレクトリ内にある`install_mcsoc.sh`を使用します。

```bash
./install_mcsoc.sh
```
<br>

# Usage

サービスは`mcsoc`コマンドを通じて提供されます。<br><br>

Minecraftサーバーを作成する際は`mcsoc create`コマンドを実行し、画面の指示に従って作成を進めてください。<br>
その際、**Minecraftサーバーのアプリケーション**またはMCSOCで作成された**バックアップデータ**のパスを指定してください。<br>
- 例: Java Editionをインストールする場合
```bash:
mcsoc create java /tmp/server.jar
```
<br>

- 例: Bedrock Editionをインストールする場合
```bash:
mcsoc create be /tmp/bedrock-server-X.XX.XX.XX.zip
```
<br>

作成したサーバーを起動するには、コンテナ名を指定して`mcsoc start`コマンドを使用します。
```bash:
mcsoc start my_server
```
<br>

起動しているサーバーを停止するには、コンテナ名を指定して`mcsoc stop`コマンドを使用します。
```bash:
mcsoc stop my_server
```
<br>

作成したサーバーを削除するには、コンテナ名を指定して`mcsoc rm`コマンドを使用します。
```bash:
mcsoc rm my_server
```
<br>

### Function

サーバーでMinecraftコマンドを実行するには、`mcsoc com`コマンドを使用します。
```bash:
mcsoc com my_server "say HELLO!"
```
<br>

### Backup

MCSOCのバックアップは2種類の方法があります。
- **FULL**: サーバーのすべてのデータをバックアップします。バックアップ時、サーバーは停止します。
- **INSTANT**: サーバーの最低限のデータをバックアップします。バックアップ時、サーバーは停止しません。
    - `mcsoc create`コマンドでサポートされるバックアップデータは**FULL**のみです。

手動でバックアップするには`mcsoc backup`コマンドを使用します。
```bash:
mcsoc backup full my_server
```

サーバー作成時に定期的なバックアップを設定することもできます。<br>
バックアップは、サーバー数に応じて以下のルールに従い実行されます。<br>
- **FULL**:  週1回 / 6時～7時の間で1回実行
- **INSTANT**: 毎日 / 3時～5時50分の間で1回実行
<br>

### Status
MCSOCのステータスを確認するには`mcsoc -s`コマンドを使用します。
```bash:
mcsoc -s
```
作成したサーバーの詳細情報を確認するには`mcsoc info`コマンドを使用します。
```bash:
mcsoc info
```

### Help
`mcsoc`コマンドに関する詳細は、ヘルプを確認してください。
```bash:
mcsoc -h
```
<br>

# Upgrade

MCSOCのバージョンをアップグレードするには、新しいバージョンのディレクトリ内にある`upgrade_mcsoc.sh`を使用します。

```bash
./upgrade_mcsoc.sh
```
<br>

# Uninstallation

MCSOCをアンインストールするには、`uninstall_mcsoc.sh`を使用します。

```bash
./uninstall_mcsoc.sh
```

# Support

Contact: kokoroq

# License

MCSOC is distributed under `MIT License`. See [LICENSE](https://github.com/kokoroq/mcso/blob/main/LICENSE)