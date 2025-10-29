@echo off
title Big Data & Neo4j Docker Launcher
color 0B
cls

:menu
echo ====================================================
echo              Big Data Analytics Menu
echo ====================================================
echo  1) Apache HBase
echo  2) Apache Cassandra
echo  3) Neo4j
echo  4) Apache Hive
echo  5) Apache Pig
echo  6) Exit
echo ====================================================
set /p choice="Enter your choice [1-6]: "

if "%choice%"=="1" goto hbase
if "%choice%"=="2" goto cassandra
if "%choice%"=="3" goto neo4j
if "%choice%"=="4" goto hive
if "%choice%"=="5" goto bigdata
if "%choice%"=="6" exit
goto menu

:hbase
cls
echo ====================================================
echo       Launching Apache HBase in Docker
echo ====================================================
docker pull dajobe/hbase
docker rm -f hbase-node >nul 2>&1
docker run -d --name hbase-node -p 2181:2181 -p 16010:16010 dajobe/hbase
echo.
echo ✅ HBase started.
echo Web UI: http://localhost:16010
echo To shell: docker exec -it hbase-node hbase shell
pause
goto menu

:cassandra
cls
echo ====================================================
echo       Launching Apache Cassandra in Docker
echo ====================================================
docker pull cassandra:latest
docker rm -f cassandra-node >nul 2>&1
docker run --name cassandra-node -d -p 9042:9042 cassandra:latest
echo.
echo ✅ Cassandra started.
echo Opening new terminal with cqlsh...
start cmd /k "docker exec -it cassandra-node cqlsh"
pause
goto menu

:neo4j
cls
echo ====================================================
echo       Launching Neo4j in Docker
echo ====================================================
set NEO4J_PASS=test12345
docker pull neo4j:latest
docker rm -f neo4j-node >nul 2>&1
docker run --name neo4j-node -d ^
 -p 7474:7474 -p 7687:7687 ^
 -e NEO4J_AUTH=neo4j/%NEO4J_PASS% ^
 neo4j:latest
echo.
echo ✅ Neo4j started.
echo Username: neo4j
echo Password: %NEO4J_PASS%
start http://localhost:7474
pause
goto menu

:hive
cls
echo ====================================================
echo       Launching Apache Hive in Docker
echo ====================================================
docker pull fredrikhgrelland/hive:latest
docker rm -f hive-server >nul 2>&1
docker run -d --name hive-server ^
    -p 10000:10000 -p 10002:10002 ^
    fredrikhgrelland/hive:latest

echo Initializing Hive schema with Derby...
docker exec -it hive-server schematool -dbType derby -initSchema

echo Applying ACID properties...
docker exec -i hive-server hive -e ^
"SET hive.support.concurrency=true; ^
 SET hive.enforce.bucketing=true; ^
 SET hive.exec.dynamic.partition.mode=nonstrict; ^
 SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager; ^
 SET hive.compactor.initiator.on=true; ^
 SET hive.compactor.worker.threads=1;"

echo.
echo ✅ Hive started with ACID enabled!
echo Connect using Beeline:
echo   docker exec -it hive-server beeline -u "jdbc:hive2://localhost:10000"
echo Or open Hive CLI inside container:
echo   docker exec -it hive-server hive
pause
goto menu

:bigdata
cls
echo ====================================================
echo                Launching Pig
echo ====================================================
docker pull suhothayan/hadoop-spark-pig-hive:2.9.2
docker rm -f bigdata-node >nul 2>&1
docker run -it --name bigdata-node ^
 -p 55070:50070 -p 58088:8088 -p 58080:8080 ^
 suhothayan/hadoop-spark-pig-hive:2.9.2 bash

echo.
echo ✅ Inside container, you can run:
echo   pig -x local       (Pig local mode)
echo   pig -x mapreduce   (Pig with Hadoop)
echo   hive               (Hive CLI)
echo   spark-shell        (Spark Shell)
pause
goto menu
