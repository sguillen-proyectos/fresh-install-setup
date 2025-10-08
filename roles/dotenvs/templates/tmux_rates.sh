#!/bin/bash

if [[ ! -f /tmp/tmuxrates.json ]]; then
  printf "USDT: <empty>"
  exit 0
fi

json=$(cat /tmp/tmuxrates.json)

buy=$(echo "$json" | jq -r '.buyPrice')
sell=$(echo "$json" | jq -r '.sellPrice')

printf "USDT: 🟢%.2f 🔴%.2f" "$buy" "$sell"

# */15 * * * * /home/donkeysharp/.local/bin/tmux_get_rates.sh
