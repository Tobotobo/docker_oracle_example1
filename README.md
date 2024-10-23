# docker_oracle_exmple1

## 概要
* 公式の Docker Images from Oracle で Oracle Database のイメージを作成・起動する

Docker Images from Oracle  
https://github.com/oracle/docker-images  

Oracle Database container images  
https://github.com/oracle/docker-images/tree/main/OracleDatabase/SingleInstance  

DockerでOracle Databaseを構築してみる  
https://qiita.com/h-i-ist/items/a67acbce0e7c6bdebd69  

## 環境  
* Ubuntu 22.04.3 LTS
* Docker 26.1.1, build 4cf5afa

## 詳細
curl と unzip コマンドが必用  ※無い場合はインストール
```
sudo apt-get install -y curl unzip
```

`download_dockerfiles.sh` を実行　
※引数で oracle/docker-images の zip への URL を指定  

最新  
https://github.com/oracle/docker-images/archive/refs/heads/main.zip  

作業時点　※2024/7/2  
https://github.com/oracle/docker-images/archive/5d3230646f5a1a954b6990a27d8e90f652750b0c.zip  

```
chmod +x ./download_dockerfiles.sh
./download_dockerfiles.sh https://github.com/oracle/docker-images/archive/5d3230646f5a1a954b6990a27d8e90f652750b0c.zip 
```

`buildContainerImage.sh` を実行  
※ 13GB の空き容量が必用で足りないと `checkSpace.sh` でエラーになる
```
./dockerfiles/buildContainerImage.sh -v 23.4.0 -f
```

完了するまでに 10 分かかった。あと何か警告出てる。  
```
～～～～～～～～～～～～～～～～～～～～

 2 warnings found (use --debug to expand):
 - FromAsCasing: 'as' and 'FROM' keywords' casing do not match (line 21)
 - UndefinedVar: Usage of undefined variable '$HOME' (line 38)


  Oracle Database container image for 'free' version 23.4.0 is ready to be extended: 
    
    --> oracle/database:23.4.0-free

  Build completed in 636 seconds.
```

出来上がったイメージは 5 GB 程度
```
vagrant@vagrant:/projects/docker_oracle_example1$ docker image ls
REPOSITORY        TAG           IMAGE ID       CREATED              SIZE
oracle/database   23.4.0-free   0c033bbfeb6a   About a minute ago   4.86GB
```

試しにコンテナ起動
```
docker run -d --name oracle-db -e ORACLE_PWD=password oracle/database:23.4.0-free
```
```
vagrant@vagrant:/projects/docker_oracle_example1$ docker ps
CONTAINER ID   IMAGE                         COMMAND                  CREATED         STATUS                            PORTS      NAMES
4c7a710aad81   oracle/database:23.4.0-free   "/bin/bash -c $ORACL…"   4 seconds ago   Up 4 seconds (health: starting)   1521/tcp   oracle-db
```

sqlplus で接続  
```
docker exec -it oracle-db bash
sqlplus system/password
```
```
bash-4.4$ sqlplus system/password

SQL*Plus: Release 23.0.0.0.0 - Production on Tue Jul 2 15:16:37 2024
Version 23.4.0.24.05

Copyright (c) 1982, 2024, Oracle.  All rights reserved.

Last Successful login time: Tue Jul 02 2024 15:14:19 +00:00

Connected to:
Oracle Database 23ai Free Release 23.0.0.0.0 - Develop, Learn, and Run for Free
Version 23.4.0.24.05

SQL> 
```
試しに SQL 実行
```
SQL> SELECT TABLE_NAME FROM USER_TABLES;

TABLE_NAME
--------------------------------------------------------------------------------
MVIEW$_ADV_WORKLOAD
MVIEW$_ADV_BASETABLE
MVIEW$_ADV_SQLDEPEND
MVIEW$_ADV_PRETTY
～～～～～～～～～～～～～～～～
HELP
REDO_DB
REDO_LOG

31 rows selected.

SQL> 
```

スキーマ内の各テーブルのレコード数を表示
```
select table_name, to_number(extractvalue(xmltype(dbms_xmlgen.getxml('select count(*) c from '||table_name)),'/ROWSET/ROW/C')) count from user_tables WHERE TABLE_NAME NOT LIKE 'BIN$%' and (iot_type != 'IOT_OVERFLOW' or iot_type is null) order by table_name;
```

## 18.4.0

```
./dockerfiles/buildContainerImage.sh -v 18.4.0 -x
```
※完了までに約 3 〜 4 分かかった。

```
REPOSITORY                                TAG                     IMAGE ID       CREATED          SIZE
oracle/database                           18.4.0-xe               5a6d06f35c49   58 seconds ago   5.9GB
```
※イメージサイズは約 6 GB

```
docker compose up
```
※初回は起動が完了するまでにかなり時間がかかる。（約 8 分かかった）  
　すぐに接続しようとするとつながらなくて混乱するので、ログを見て完了したか確認した方が良い。

```
$ docker compose up
[+] Running 3/1
 ✔ Network docker_oracle_example1_default        Created                                                                                                                                                          0.1s 
 ✔ Volume "docker_oracle_example1_oradata"       Created                                                                                                                                                          0.0s 
 ✔ Container docker_oracle_example1-oracle-db-1  Created                                                                                                                                                          0.1s 
Attaching to oracle-db-1
oracle-db-1  | ORACLE PASSWORD FOR SYS AND SYSTEM: password
oracle-db-1  | Specify a password to be used for database accounts. Oracle recommends that the password entered should be at least 8 characters in length, contain at least 1 uppercase character, 1 lower case character and 1 digit [0-9]. Note that the same password will be used for SYS, SYSTEM and PDBADMIN accounts:
oracle-db-1  | Confirm the password:
oracle-db-1  | Configuring Oracle Listener.
oracle-db-1  | Listener configuration succeeded.
oracle-db-1  | Configuring Oracle Database XE.
oracle-db-1  | Enter SYS user password: 
oracle-db-1  | *******
oracle-db-1  | Enter SYSTEM user password: 
oracle-db-1  | **********
oracle-db-1  | Enter PDBADMIN User Password: 
oracle-db-1  | *********
oracle-db-1  | Prepare for db operation
oracle-db-1  | 7% complete
oracle-db-1  | Copying database files
oracle-db-1  | 29% complete
oracle-db-1  | Creating and starting Oracle instance
oracle-db-1  | 30% complete
oracle-db-1  | 31% complete
oracle-db-1  | 34% complete
oracle-db-1  | 38% complete
oracle-db-1  | 41% complete
oracle-db-1  | 43% complete
oracle-db-1  | Completing Database Creation
oracle-db-1  | 47% complete
oracle-db-1  | 50% complete
oracle-db-1  | Creating Pluggable Databases
oracle-db-1  | 54% complete
oracle-db-1  | 71% complete
oracle-db-1  | Executing Post Configuration Actions
oracle-db-1  | 93% complete
oracle-db-1  | Running Custom Scripts
oracle-db-1  | 100% complete
oracle-db-1  | Database creation complete. For details check the logfiles at:
oracle-db-1  |  /opt/oracle/cfgtoollogs/dbca/XE.
oracle-db-1  | Database Information:
oracle-db-1  | Global Database Name:XE
oracle-db-1  | System Identifier(SID):XE
oracle-db-1  | Look at the log file "/opt/oracle/cfgtoollogs/dbca/XE/XE.log" for further details.
oracle-db-1  | 
oracle-db-1  | Connect to Oracle Database using one of the connect strings:
oracle-db-1  |      Pluggable database: df148c2cf5bb/XEPDB1
oracle-db-1  |      Multitenant container database: df148c2cf5bb
oracle-db-1  | Use https://localhost:5500/em to access Oracle Enterprise Manager for Oracle Database XE
oracle-db-1  | The Oracle base remains unchanged with value /opt/oracle
oracle-db-1  | #########################
oracle-db-1  | DATABASE IS READY TO USE!
oracle-db-1  | #########################
oracle-db-1  | The following output is now a tail of the alert.log:
oracle-db-1  | Pluggable database XEPDB1 opened read write
oracle-db-1  | Completed: alter pluggable database XEPDB1 open
oracle-db-1  | 2024-10-22T13:29:52.439230+00:00
oracle-db-1  | XEPDB1(3):CREATE SMALLFILE TABLESPACE "USERS" LOGGING  DATAFILE  '/opt/oracle/oradata/XE/XEPDB1/users01.dbf' SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT  AUTO
oracle-db-1  | XEPDB1(3):Completed: CREATE SMALLFILE TABLESPACE "USERS" LOGGING  DATAFILE  '/opt/oracle/oradata/XE/XEPDB1/users01.dbf' SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT  AUTO
oracle-db-1  | XEPDB1(3):ALTER DATABASE DEFAULT TABLESPACE "USERS"
oracle-db-1  | XEPDB1(3):Completed: ALTER DATABASE DEFAULT TABLESPACE "USERS"
oracle-db-1  | 2024-10-22T13:29:53.195522+00:00
oracle-db-1  | ALTER PLUGGABLE DATABASE XEPDB1 SAVE STATE
oracle-db-1  | Completed: ALTER PLUGGABLE DATABASE XEPDB1 SAVE STATE
```

2 回目以降はわりとすぐ起動する。
```
$ docker compose up
[+] Running 2/1
 ✔ Network docker_oracle_example1_default        Created                                                                                                                                                          0.1s 
 ✔ Container docker_oracle_example1-oracle-db-1  Created                                                                                                                                                          0.1s 
Attaching to oracle-db-1
oracle-db-1  | The Oracle base remains unchanged with value /opt/oracle
oracle-db-1  | #########################
oracle-db-1  | DATABASE IS READY TO USE!
oracle-db-1  | #########################
oracle-db-1  | The following output is now a tail of the alert.log:
oracle-db-1  | XEPDB1(3):[216] Successfully onlined Undo Tablespace 2.
oracle-db-1  | XEPDB1(3):Undo initialization online undo segments: err:0 start: 27828560 end: 27828581 diff: 21 ms (0.0 seconds)
oracle-db-1  | XEPDB1(3):Undo initialization finished serial:0 start:27828559 end:27828582 diff:23 ms (0.0 seconds)
oracle-db-1  | XEPDB1(3):Database Characterset for XEPDB1 is AL32UTF8
oracle-db-1  | XEPDB1(3):Opening pdb with Resource Manager plan: DEFAULT_PLAN
oracle-db-1  | Pluggable database XEPDB1 opened read write
oracle-db-1  | Starting background process CJQ0
oracle-db-1  | 2024-10-22T13:50:55.377351+00:00
oracle-db-1  | CJQ0 started with pid=43, OS id=477 
oracle-db-1  | Completed: ALTER DATABASE OPEN
oracle-db-1  | 2024-10-22T13:50:55.983639+00:00
oracle-db-1  | Shared IO Pool defaulting to 48MB. Trying to get it from Buffer Cache for process 174.
oracle-db-1  | ===========================================================
oracle-db-1  | Dumping current patch information
oracle-db-1  | ===========================================================
oracle-db-1  | No patches have been applied
oracle-db-1  | ===========================================================
```

```
docker compose exec oracle-db bash

# sqlplus / as sysdba ※ERROR:ORA-12547: TNS:lost contact

# CDB に接続する場合
sqlplus sys/password@XE as sysdba

# PDB に接続する場合
sqlplus sys/password@XEPDB1 as sysdba

sqlplus sys/password@XEPDB1 as sysoper
sqlplus system/password@XEPDB1
sqlplus pdbadmin/password@XEPDB1

SELECT TABLE_NAME FROM USER_TABLES;
```

```
cd /backup
rman target / cmdfile=/backup/backup_script.rman log=/backup/backup_log.txt　※エラー

rman target sys/password@XEPDB1 cmdfile=/backup/backup_script.rman log=/backup/backup_log.txt

```

```

sqlplus sys/password@XEPDB1 as sysdba
SQL> shutdown immediate;

rman target sys/password@XEPDB1 cmdfile=/backup/backup_script.rman log=/backup/backup_log.txt

sqlplus sys/password@XEPDB1 as sysdba
SQL> startup;

```

```
rman target sys/password@XEPDB1 cmdfile=/backup/restore_script.rman log=/backup/restore_log.txt
```

```
expdp system/password@XEPDB1 schemas=system \
    directory=/backup/export dumpfile=your_schema.dmp logfile=export.log

```

```
CREATE TABLE employees (id NUMBER PRIMARY KEY,name VARCHAR2(50),age NUMBER);
SELECT * FROM employees;
INSERT INTO employees (id, name, age) VALUES (1, '山田 太郎', 30);
```

Oracle Database 12cを使ってみよう  
マルチテナント・アーキテクチャ編 第3回　バックアップ＆リカバリ  
https://www.oracle.com/jp/technical-resources/articles/jissenn12c/jissen12c-03.html