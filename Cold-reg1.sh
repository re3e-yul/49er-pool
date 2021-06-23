rm -f ./pool.cert ./deleg.cert
cardano-cli stake-pool registration-certificate \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --vrf-verification-key-file vrf.vkey \
    --pool-pledge 100000000000 \
    --pool-cost 340000000 \
    --pool-margin 0.01 \
    --pool-reward-account-verification-key-file stake.vkey \
    --pool-owner-stake-verification-key-file stake.vkey \
    --testnet-magic 1097911063 \
    --pool-relay-ipv4 107.159.16.161 \
    --pool-relay-port 9001 \
    --metadata-url https://git.io/JnXZk \
    --metadata-hash $(cat poolMetaDataHash.txt) \
    --out-file pool.cert
cardano-cli stake-address delegation-certificate \
    --stake-verification-key-file stake.vkey \
    --cold-verification-key-file $HOME/cold-keys/node.vkey \
    --out-file deleg.cert
 scp ./pool.cert ubuntu@192.168.1.10:
 scp ./deleg.cert ubuntu@192.168.1.10:
