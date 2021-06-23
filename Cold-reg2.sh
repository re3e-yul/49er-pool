chmod 777 ./tx.raw
cardano-cli transaction sign \
    --tx-body-file tx.raw \
    --signing-key-file payment.skey \
    --signing-key-file $HOME/cold-keys/node.skey \
    --signing-key-file stake.skey \
    --testnet-magic 1097911063 \
    --out-file tx.signed
scp ./tx.signed ubuntu@192.168.1.10:
