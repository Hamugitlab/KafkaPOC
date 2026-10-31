#!/usr/bin/env bash
set -euo pipefail

KAFKA_BIN="${KAFKA_BIN:-/bin/kafka-topics.sh}"
BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"

if ! command -v kafka-topics.sh >/dev/null 2>&1; then
  echo "kafka-topics.sh not found in PATH. Please set KAFKA_BIN or run this inside the Kafka container."
  exit 1
fi

TOPICS=(
  "oracle.orders"
  "oracle.customers"
  "oracle.dbhistory"
  "connect-configs"
  "connect-offsets"
  "connect-status"
)

for topic in "${TOPICS[@]}"; do
  echo "Creating topic: ${topic}"
  kafka-topics.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --create --topic "${topic}" --partitions 3 --replication-factor 1 --if-not-exists || true
done

echo "Kafka topics are ready."
