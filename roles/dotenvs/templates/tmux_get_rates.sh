#!/bin/bash

json=$(curl -s https://rates-server.vercel.app/api/prices)
echo $json > /tmp/tmuxrates.json

buy=$(echo "$json" | jq -r '.buyPrice')
sell=$(echo "$json" | jq -r '.sellPrice')

printf "USDT: 🟢 %.2f 🔴 %.2f" "$buy" "$sell"
