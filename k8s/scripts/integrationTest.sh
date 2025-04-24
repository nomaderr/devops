#!/bin/bash

set -e

FLEET_URL="http://fleet.34.77.188.249.nip.io"

EMAIL="${FLEET_EMAIL}"
PASSWORD="${FLEET_PASSWORD}"

echo "Authenticating"
TOKEN=$(curl -s -X POST "${FLEET_URL}/api/v1/fleet/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\", \"password\":\"${PASSWORD}\"}" | jq -r .token)

if [ "$TOKEN" == "null" ] || [ -z "$TOKEN" ]; then
  echo "Failed to authenticate and retrieve token"
  exit 1
fi

echo "Token received"

echo "📡 Requesting enroll secret"
RESPONSE=$(curl -s -X GET "${FLEET_URL}/api/v1/fleet/spec/enroll_secret" \
  -H "Authorization: Bearer $TOKEN")

echo "$RESPONSE" | jq .spec.secrets &> /dev/null

if [ $? -ne 0 ]; then
  echo "Enroll secret not found in response"
  exit 1
fi

echo "Enroll secret present — integration test passed"
