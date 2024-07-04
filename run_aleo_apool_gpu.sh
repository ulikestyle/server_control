#!/bin/bash
if ps aux | grep 'apoolminer' | grep -q 'apool.io'; then
    echo "ApoolMiner already running."
    exit 1
else
    nohup  ./apoolminer --pool aleo1.hk.apool.io:9090 --account CP_32hb86nvxc --worker worker_01 -A aleo -g 0 >> aleo.log 2>&1 &
fi

