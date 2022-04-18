#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

$PSQL "TRUNCATE customers cascade"
$PSQL "ALTER SEQUENCE customers_customer_id_seq RESTART WITH 1"
