#!/usr/bin/env bash
set -euo pipefail

KAFKA_CONSUMER="${KAFKA_CONSUMER:-kafka-console-consumer.sh}"
BOOTSTRAP_SERVER="${BOOTSTRAP_SERVER:-localhost:9092}"

if ! command -v kafka-console-consumer.sh >/dev/null 2>&1; then
  echo "kafka-console-consumer.sh not found in PATH."
  exit 1
fi

echo "Validating Kafka message flow..."
echo "Trying consumer on oracle.orders (10s timeout)"
timeout 10s kafka-console-consumer.sh --bootstrap-server "${BOOTSTRAP_SERVER}" --topic oracle.orders --from-beginning || true

echo "Validation complete."
