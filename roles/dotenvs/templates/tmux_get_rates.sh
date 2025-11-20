#!/bin/bash

json=$(curl -sS https://dolarboliviahoy.com/api/exchangeData)
echo $json > /tmp/tmuxrates.json

buy=$(echo $json | jq -r '.buyAveragePrice')
sell=$(echo $json | jq -r '.sellAveragePrice')

printf "USDT: 🟢 %.2f 🔴 %.2f" "$buy" "$sell"
