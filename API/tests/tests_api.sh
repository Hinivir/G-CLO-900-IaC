#!/usr/bin/env bash
set -e

URL="http://localhost:18080"

echo "🧪 Test création..."
curl -s -X POST -H "Content-Type: application/json" -d '{"name":"foo"}' $URL/items | jq .

echo "🧪 Test lecture..."
curl -s $URL/items | jq .

echo "✅ Tous les tests API Go sont passés."