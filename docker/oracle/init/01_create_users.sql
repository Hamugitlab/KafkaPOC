CREATE USER appuser IDENTIFIED BY "AppPass_123";
GRANT CONNECT, RESOURCE TO appuser;
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE VIEW TO appuser;
GRANT CREATE PROCEDURE, CREATE TRIGGER TO appuser;

CREATE TABLE appuser.orders (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id VARCHAR2(50) NOT NULL,
    customer_id VARCHAR2(50),
    status VARCHAR2(30),
    amount NUMBER(10,2),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE TABLE appuser.customers (
    id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id VARCHAR2(50) NOT NULL,
    first_name VARCHAR2(100),
    last_name VARCHAR2(100),
    email VARCHAR2(255),
    created_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

INSERT INTO appuser.customers (customer_id, first_name, last_name, email)
VALUES ('CUST-001', 'Alice', 'Jones', 'alice@example.com');

INSERT INTO appuser.customers (customer_id, first_name, last_name, email)
VALUES ('CUST-002', 'Bob', 'Smith', 'bob@example.com');
