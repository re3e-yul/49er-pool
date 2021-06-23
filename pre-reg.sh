currentSlot=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.slot')
echo Current Slot: $currentSlot
cardano-cli query utxo  --address $(cat payment.addr)  --testnet-magic 1097911063 > fullUtxo.out
tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
#cat balance.out
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    echo TxHash: ${in_addr}#${idx}
    echo ADA: ${utxo_balance}
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
echo Number of UTXOs: ${txcnt}
keyDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakeAddressDeposit')
echo keyDeposit: $keyDeposit
cardano-cli transaction build-raw ${tx_in} --tx-out $(cat payment.addr)+0  --ttl $(( ${currentSlot} + 10000))  --fee 0 --out-file tx.tmp  --certificate stake.cert
fee=$(cardano-cli transaction calculate-min-fee --tx-body-file tx.tmp  --tx-in-count ${txcnt}  --tx-out-count 1  --testnet-magic 1097911063 --witness-count 2  --byron-witness-count 0 --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
echo TBalance: $total_balance
echo KeyDeposit: $keyDeposit
txOut=$((${total_balance}-${keyDeposit}-${fee}))
echo Change Output: ${txOut}
cardano-cli transaction build-raw  ${tx_in} --tx-out $(cat payment.addr)+${txOut}  --ttl $(( ${currentSlot} + 10000))  --fee ${fee}  --certificate-file stake.cert  --out-file tx.raw
cardano-cli transaction sign  --tx-body-file tx.raw  --signing-key-file payment.skey  --signing-key-file stake.skey  --testnet-magic 1097911063  --out-file tx.signed
cardano-cli transaction submit  --tx-file tx.signed  --testnet-magic 1097911063
