# docker_oracle_exmple1

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