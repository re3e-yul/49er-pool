#! /bin/sh
slotsPerKESPeriod=$(cat $NODE_HOME/${NODE_CONFIG}-shelley-genesis.json | jq -r '.slotsPerKESPeriod')
slotNo=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.slot')
kesPeriod=$((${slotNo} / ${slotsPerKESPeriod}))
startKesPeriod=${kesPeriod}
blockNo=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.block')
eraNo=$(cardano-cli query tip --testnet-magic 1097911063 | jq -r '.era')

date +'%D %T'
echo eraNo: ${eraNo}
echo slotNo: ${slotNo}
echo blockNo: ${blockNo}
echo ""
echo slotsPerKESPeriod: ${slotsPerKESPeriod}
echo kesPeriod: ${kesPeriod}
echo startKesPeriod: ${startKesPeriod}
