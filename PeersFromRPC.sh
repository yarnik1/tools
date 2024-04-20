#!/bin/bash

RPC="<--SET_RPC-->"

n_peers=$(curl -s "${RPC}/net_info?" | jq -r '.result.n_peers')
((n_peers--))
echo -n "${RPC}," >> /root/RPC.txt
PEER=$(curl -s "${RPC}/status?" | jq -r '.result.node_info.listen_addr')
id=$(curl -s "${RPC}/status?" | jq -r '.result.node_info.id')
echo -n "${id}@${PEER}," >> /root/PEER.txt
echo "${id}@${PEER}"
p=0
count=0
echo "Search peers..."
while [[ "$p" -le "$n_peers" ]] && [[ "$count" -le 20 ]]; do
    PEER=$(curl -s "${RPC}/net_info?" | jq -r ".result.peers[$p].node_info.listen_addr")
    if [[ ! "$PEER" =~ "tcp" ]]; then
        id=$(curl -s "${RPC}/net_info?" | jq -r ".result.peers[$p].node_info.id")
        echo -n "${id}@${PEER}," >> /root/PEER.txt
        echo "${id}@${PEER}"
        ADDRESS=${PEER%:*}
        PORT=${PEER##*:}
        ((PORT++))
        RPC="${ADDRESS}:${PORT}"
        if [[ $(curl -s "http://${RPC}/abci_info?" --connect-timeout 5 | jq -r '.result.response.last_block_height') -gt 0 ]]; then
            echo "${RPC}"
            echo -n "${RPC}," >> /root/RPC.txt
            RPC=""
        fi
    fi
    ((p++))
done
echo "Search peers is complete!"
PEER=$(sed 's/,$//' /root/PEER.txt)
RPC=$(sed 's/,$//' /root/RPC.txt)
