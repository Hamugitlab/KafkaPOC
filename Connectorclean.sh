#!/bin/bash

echo "=== DELETE OLD CONNECTORS ==="
curl -X DELETE http://localhost:8083/connectors/oracle-source-hr-03
curl -X DELETE http://localhost:8083/connectors/oracle-sqlserver-sink-02

echo "=== DELETE SCHEMA HISTORY TOPIC ==="
docker exec broker kafka-topics --bootstrap-server broker:29092 --delete --topic schema-changes.oracle

echo "=== DELETE HR TOPICS ==="

docker exec -it broker bash

for t in $(kafka-topics --bootstrap-server broker:9092 --list | grep '^oracle'); do kafka-topics --bootstrap-server broker:9092 --delete --topic "$t"; done



#!/bin/bash

BROKER="broker:29092"

echo "=== DELETE BROKEN INTERNAL TOPICS ==="
kafka-topics --bootstrap-server $BROKER --topic docker-connect-offsets --delete
kafka-topics --bootstrap-server $BROKER --topic docker-connect-configs --delete
kafka-topics --bootstrap-server $BROKER --topic docker-connect-status --delete

echo "=== WAIT FOR DELETION ==="
sleep 5

echo "=== RECREATE INTERNAL TOPICS WITH COMPACT POLICY ==="
kafka-topics --bootstrap-server $BROKER \
  --topic docker-connect-offsets \
  --create --partitions 1 --replication-factor 1 \
  --config cleanup.policy=compact

kafka-topics --bootstrap-server $BROKER \
  --topic docker-connect-configs \
  --create --partitions 1 --replication-factor 1 \
  --config cleanup.policy=compact

kafka-topics --bootstrap-server $BROKER \
  --topic docker-connect-status \
  --create --partitions 1 --replication-factor 1 \
  --config cleanup.policy=compact

echo "=== INTERNAL TOPICS FIXED ==="


exit

docker exec -it connect bash



echo "=== RECREATE CLEAN SOURCE CONNECTOR ==="
rm oracle-source-hr-08.json
cat > oracle-source-hr-08.json << 'EOF'
{
  "name": "oracle-source-hr-08",
  "config": {
    "connector.class": "io.debezium.connector.oracle.OracleConnector",

    "database.hostname": "himorcl",
    "database.port": "1521",
    "database.user": "debezium",
    "database.password": "debezium",

    "database.dbname": "ORACL",
   
    "topic.prefix": "oracle",

    "schema.history.internal.kafka.bootstrap.servers": "broker:29092",
    "schema.history.internal.kafka.topic": "schema-changes.oracle",

    "table.include.list": "HR.EMPLOYEES,HR.DEPARTMENTS,HR.JOBS,HR.COUNTRIES,HR.LOCATIONS,HR.REGIONS,HR.JOB_HISTORY",

    "snapshot.mode": "initial",

    "decimal.handling.mode": "double",
    "binary.handling.mode": "base64",
    "time.precision.mode": "adaptive",

    "tombstones.on.delete": "false",
    "include.schema.changes": "false",

    "log.mining.strategy": "online_catalog",
    "log.mining.continuous.mine": "false",

    "log.mining.archive.log.only.mode": "false",
    "log.mining.archive.destination.name": "LOG_ARCHIVE_DEST_1",
    "log.mining.start.scn": "-1",

    "log.mining.sleep.time.default": "5000",
    "log.mining.batch.size.default": "1000",
	"transforms": "unwrap",
	"transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
	"transforms.unwrap.delete.handling.mode": "rewrite",	
	"transforms.unwrap.drop.tombstones": "false",
	"tombstones.on.delete": "true",


    "event.processing.failure.handling.mode": "warn"
  }
}
EOF

curl -X POST -H "Content-Type: application/json" \
  --data @oracle-source-hr-08.json \
  http://localhost:8083/connectors

echo "=== RECREATE CLEAN SINK CONNECTOR ==="

rm oracle-sqlserver-sink-02.json
cat > oracle-sqlserver-sink-02.json << 'EOF'
{
  "name": "oracle-sqlserver-sink-02",
  "config": {
    "connector.class": "io.confluent.connect.jdbc.JdbcSinkConnector",
    "tasks.max": "1",

    "topics": "oracle.HR.EMPLOYEES,oracle.HR.DEPARTMENTS,oracle.HR.JOBS,oracle.HR.COUNTRIES,oracle.HR.LOCATIONS,oracle.HR.REGIONS,oracle.HR.JOB_HISTORY",

    "transforms": "unwrap,route",

    "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
    "transforms.unwrap.delete.handling.mode": "rewrite",
    "transforms.unwrap.drop.tombstones": "false",

    "transforms.route.type": "org.apache.kafka.connect.transforms.RegexRouter",
    "transforms.route.regex": "oracle\\.(.*)\\.(.*)",
    "transforms.route.replacement": "$2",

    "connection.url": "jdbc:sqlserver://him-mssql_01:1433;databaseName=oraclehr;encrypt=false;trustServerCertificate=true",
    "connection.user": "sa",
    "connection.password": "hello@123",

    "insert.mode": "upsert",
    "delete.enabled": "true",
    "pk.mode": "record_key",
    "table.name.format": "${topic}",

    "auto.create": "true",
    "auto.evolve": "true"
  }
}
EOF

curl -X POST -H "Content-Type: application/json" \
  --data @oracle-sqlserver-sink-02.json \
  http://localhost:8083/connectors

echo "=== RESET COMPLETE ==="



https://docs.confluent.io/kafka-connectors/oracle-cdc/current/examples.html