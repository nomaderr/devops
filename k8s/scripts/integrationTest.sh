#!/bin/bash
set -e

FLEET_URL="https://fleet.34.77.188.249.nip.io"

EMAIL="${FLEET_EMAIL}"
PASSWORD="${FLEET_PASSWORD}"

echo "Authenticating..."
RESPONSE=$(curl -skL -X POST "${FLEET_URL}/api/v1/fleet/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"${EMAIL}\", \"password\":\"${PASSWORD}\"}")

TOKEN=$(echo "$RESPONSE" | jq -r .token)

if [[ "$TOKEN" == "null" || -z "$TOKEN" ]]; then
  echo "❌ Failed to authenticate and retrieve token"
  echo "$RESPONSE"
  exit 1
fi

echo "✅ Token received: ${TOKEN:0:10}..."

echo "Requesting enroll secret..."
SECRET_RESPONSE=$(curl -skL -X GET "${FLEET_URL}/api/v1/fleet/spec/enroll_secret" \
  -H "Authorization: Bearer $TOKEN")

echo "$SECRET_RESPONSE" | jq .spec.secrets &> /dev/null

if [ $? -ne 0 ]; then
  echo "❌ Enroll secret not found in response"
  echo "$SECRET_RESPONSE"
  exit 1
fi

echo "✅ Enroll secret present — integration test passed"
