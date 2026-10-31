# Kafka Oracle POC Architecture

## Overview

This project demonstrates a simple event-driven pipeline where Oracle database transactions are captured and published to Kafka topics for downstream processing.

## Components

- Oracle database: source of business records
- Kafka broker: message backbone
- Kafka Connect: CDC or JDBC integration layer
- Schema Registry: optional metadata management for encoded messages
- Consumer services: downstream processors or monitoring tools

## Proposed data flow

1. Data is inserted or updated in Oracle tables.
2. Kafka Connect captures row-level changes using Debezium or JDBC connectors.
3. Events are published to Kafka topics such as `oracle.orders` and `oracle.customers`.
4. Consumers read from those topics and process or enrich the messages.
5. Monitoring stack tracks broker health, lag, and topic activity.

## Example topics

- `oracle.orders`
- `oracle.customers`
- `dbhistory.oracle`
- `connect-configs`
- `connect-offsets`
- `connect-status`

## Operational notes

- Ensure network access between the Kafka Connect container and Oracle database.
- Validate JDBC credentials and table privileges before starting source connectors.
- Use Kafka UI or console consumers to inspect topic payloads during the POC.
