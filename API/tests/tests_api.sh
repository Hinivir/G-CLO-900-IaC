#!/usr/bin/env bash
set -e

echo "1️⃣ Création d'un item..."
curl -s -X POST http://localhost:18080/items \
    -H "Content-Type: application/json" \
    -d '{"name":"Laptop","description":"Dell"}' | jq .

echo "2️⃣ Liste des items..."
curl -s http://localhost:18080/items | jq .

echo "3️⃣ Récupération de l'item 1..."
curl -s http://localhost:18080/items/1 | jq .

echo "4️⃣ Mise à jour..."
curl -s -X PUT http://localhost:18080/items/1 \
    -H "Content-Type: application/json" \
    -d '{"description":"Dell XPS 13"}' | jq .

echo "5️⃣ Suppression..."
curl -s -X DELETE http://localhost:18080/items/1 -i