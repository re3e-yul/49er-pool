clear
cardano-cli  stake-pool metadata-hash --pool-metadata-file poolMetaData.json > poolMetaDataHash.txt
scp ./poolMetaDataHash.txt ubuntu@192.168.1.20
rm -f ./tx.* ../tx.*
rm -f ./pool.cert ../pool.cert 
rm -f ./deleg.cert ../deleg.cert
ssh ubuntu@192.168.1.20 "/bin/bash /home/ubuntu/cold-reg1.sh"
sleep 4
currentSlot=$(cardano-cli  query tip --testnet-magic 1097911063 | jq -r '.slot')
echo Current Slot: $currentSlot
cardano-cli  query utxo \
    --address $(cat payment.addr) \
    --testnet-magic 1097911063 > fullUtxo.out
tail -n +3 fullUtxo.out | sort -k3 -nr > balance.out
cat balance.out
tx_in=""
total_balance=0
while read -r utxo; do
    in_addr=$(awk '{ print $1 }' <<< "${utxo}")
    idx=$(awk '{ print $2 }' <<< "${utxo}")
    utxo_balance=$(awk '{ print $3 }' <<< "${utxo}")
    total_balance=$((${total_balance}+${utxo_balance}))
    tx_in="${tx_in} --tx-in ${in_addr}#${idx}"
done < balance.out
txcnt=$(cat balance.out | wc -l)
echo Total ADA balance: ${total_balance}
#echo Number of UTXOs: ${txcnt}
poolDeposit=$(cat $NODE_HOME/params.json | jq -r '.stakePoolDeposit')
echo poolDeposit: $poolDeposit
cp ../pool.cert ./
cp ../deleg.cert ./
cardano-cli  transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+$(( ${total_balance} - ${poolDeposit}))  \
    --ttl $(( ${currentSlot} + 1000000)) \
    --fee 0 \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.tmp

fee=$(cardano-cli transaction calculate-min-fee \
    --tx-body-file tx.tmp \
    --tx-in-count ${txcnt} \
    --tx-out-count 1 \
    --testnet-magic 1097911063 \
    --witness-count 3 \
    --byron-witness-count 0 \
    --protocol-params-file params.json | awk '{ print $1 }')
echo fee: $fee
#txOut=$((${total_balance}-${poolDeposit}-${fee}))
txOut=$((${total_balance}-${fee}))
echo balance: ${txOut}
cardano-cli transaction build-raw \
    ${tx_in} \
    --tx-out $(cat payment.addr)+${txOut} \
    --ttl $(( ${currentSlot} + 10000)) \
    --fee ${fee} \
    --certificate-file pool.cert \
    --certificate-file deleg.cert \
    --out-file tx.raw

scp tx.raw ubuntu@192.168.1.20:
rm -f ./tx.signed
rm -f ../tx.signed
ssh ubuntu@192.168.1.20 "/home/ubuntu/cold-reg2.sh"
sleep 3
cp ../tx.signed  ./
cardano-cli transaction submit \
    --tx-file tx.signed \
    --testnet-magic 1097911063
