#! /bin/bash
clear
date +'%D %T'
cat payment.addr
cardano-cli query utxo --address $(cat payment.addr) --testnet-magic 1097911063

