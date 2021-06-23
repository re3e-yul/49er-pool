export NODE_HOME=/home/ubuntu/cardano-my-node
DIRECTORY=$NODE_HOME
PORT=9000
HOSTADDR=0.0.0.0
#TOPOLOGY=${DIRECTORY}/testnet-topology.json
TOPOLOGY=/home/ubuntu/cardano-my-node/testnet-topology.json
DB_PATH=${DIRECTORY}/db
SOCKET_PATH=${DIRECTORY}/db/socket
CONFIG=${DIRECTORY}/testnet-config.json
KES=${DIRECTORY}/kes.skey
VRF=${DIRECTORY}/vrf.skey
CERT=${DIRECTORY}/node.cert
cardano-node run --topology ${TOPOLOGY} --database-path ${DB_PATH} --socket-path ${SOCKET_PATH} --host-addr ${HOSTADDR} --port ${PORT} --config ${CONFIG} --shelley-kes-key ${KES} --shelley-vrf-key ${VRF} --shelley-operational-certificate ${CERT}
