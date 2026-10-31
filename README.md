# Kafka Oracle POC

This repository is a proof-of-concept for streaming data from Oracle into Kafka and validating the end-to-end flow using Kafka Connect, schema handling, and monitoring.

## Goals

- Run Kafka, Zookeeper, and Kafka Connect locally or in a Kubernetes test cluster
- Capture changes from Oracle using Debezium or JDBC source connectors
- Produce and consume events through Kafka topics
- Validate message flow and troubleshoot issues using logs and dashboards

## Repository layout

```text
KafkaPOC/
├── README.md
├── .gitignore
├── docker/
│   ├── docker-compose.yml
│   ├── kafka/
│   │   └── server.properties
│   ├── oracle/
│   │   └── init/
│   │       └── 01_create_users.sql
│   ├── connect/
│   │   └── connector-config/
│   │       └── source-oracle.json
│   └── monitoring/
│       └── README.md
├── scripts/
│   ├── bootstrap_topics.sh
│   └── validate_flow.sh
├── docs/
│   └── architecture.md
└── k8s/
    └── kind-config.yaml
```

## Quick start

1. Review `docker/docker-compose.yml`
2. Start infrastructure with Docker Compose
3. Deploy Kafka Connect source connector
4. Verify data flow through Kafka topics
5. Use `scripts/validate_flow.sh` to smoke-test the pipeline

## Notes

- This repo is intended for experimentation and learning.
- For production use, add secrets management, RBAC, schema registry, and health checks.
