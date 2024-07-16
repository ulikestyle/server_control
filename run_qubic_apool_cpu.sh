#!/bin/bash
account=$1
worker=$2
echo $worker
echo $account

sudo rm -rf aleo_gpu
sudo mkdir aleo_gpu
cd aleo_gpu

sudo wget https://github.com/apool-io/apoolminer/releases/download/v1.6.10/apoolminer_linux_v1.6.10.tar
sudo tar -xvf apoolminer_linux_v1.6.10.tar

if ps aux | grep 'apoolminer' | grep -q 'apool.io'; then
    echo "ApoolMiner already running."
    exit 1
else
    nohup ./apoolminer --account $account --worker $worker --gpu-off --pool qubic1.hk.apool.io:3334 &
fi
