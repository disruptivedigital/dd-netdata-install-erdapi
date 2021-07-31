#!/bin/bash
node=$1
fileName=elrond.chart.sh
echo "Generating $fileName"

## Static block 1st
cat << STATICEOF > "$fileName"
# Elrond real-time node performance and health monitoring
# powered by DisruptiveDigital 2020-2021

# shellcheck shell=bash
# no need for shebang - this file is loaded from charts.d.plugin

# if this chart is called elrond.chart.sh, then all functions and global variables
# must start with elrond_

# update_every is a special variable - it holds the number of seconds
# between the calls of the _update() function
elrond_update_every=10

# the priority is used to sort the charts on the dashboard
# 1 = the first chart
elrond_priority=1

# to enable this chart, you have to set this to 12345
# (just a demonstration for something that needs to be checked)
elrond_magic_number=12345

STATICEOF

## Generate Node variables 2nd
function generateVariable() {

  cat <<EOF >> "$fileName"
# global variables to store our collected data
# remember: they need to start with the module name elrond_priority
EOF

  configNode=(current_round synced_round node_type peer_type shard_id app_version epoch_number connected_peers connected_validators connected_nodes bls tempRating count_consensus count_consensus_accepted_blocks count_leader count_accepted_blocks num_leader_success num_leader_failure num_validator_success num_validator_failure num_validator_ignored_signatures total_num_leader_success total_num_leader_failure total_num_validator_success total_num_validator_failure total_num_validator_ignored_signatures)
  prefix="elrond_"

  for config in "${configNode[@]}"; do
    for n in $(seq 0 `expr $node - 1`)
    do
      echo "$prefix$config""_node$n=" >> "$fileName"
    done
  done
}

function generateQuery() {

  # Define sample variable 
  declare -a querySample
  read -r -d '' querySample[0] << EOF
  elrond_current_round_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_current_round )"
EOF
  read -r -d '' querySample[1] << EOF
  elrond_synced_round_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_synchronized_round )"
EOF
  read -r -d '' querySample[2] << EOF
  elrond_node_type_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_node_type )"
EOF
  read -r -d '' querySample[3] << EOF
  elrond_peer_type_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_peer_type )"
EOF
  read -r -d '' querySample[4] << EOF
  elrond_shard_id_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_shard_id | head -c2 )"
EOF
  read -r -d '' querySample[5] << EOF
  elrond_app_version_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_app_version | head -c10 )"
EOF
  read -r -d '' querySample[6] << EOF
  elrond_epoch_number_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_epoch_number )"
EOF
  read -r -d '' querySample[7] << EOF
  elrond_connected_peers_node0="\$( curl -sSL http://localhost:8080/node/status | jq .data.metrics.erd_num_connected_peers )"
EOF
  read -r -d '' querySample[8] << EOF
  elrond_connected_validators_node0="\$( curl -sSL http://localhost:8080/node/heartbeatstatus | jq '.' | grep peerType | grep -c -v observer )"
EOF
  read -r -d '' querySample[9] << EOF
  elrond_connected_nodes_node0="\$( curl -sSL http://localhost:8080/node/status | jq .data.metrics.erd_connected_nodes )"
EOF
  read -r -d '' querySample[10] << EOF
  elrond_bls_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_public_key_block_sign )"
EOF
  read -r -d '' querySample[11] << EOF
  elrond_tempRating_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".tempRating' | head -c5 )"
EOF
  read -r -d '' querySample[12] << EOF
  elrond_count_consensus_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_consensus )"
EOF
  read -r -d '' querySample[13] << EOF
  elrond_count_consensus_accepted_blocks_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_consensus_accepted_blocks )"
EOF
  read -r -d '' querySample[14] << EOF
  elrond_count_leader_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_leader )"
EOF
  read -r -d '' querySample[15] << EOF
  elrond_count_accepted_blocks_node0="\$( curl -sSL http://localhost:8080/node/status | jq -r .data.metrics.erd_count_accepted_blocks )"
EOF
  read -r -d '' querySample[16] << EOF
  elrond_num_leader_success_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".numLeaderSuccess' )"
EOF
  read -r -d '' querySample[17] << EOF
  elrond_num_leader_failure_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".numLeaderFailure' )"
EOF
  read -r -d '' querySample[18] << EOF
  elrond_num_validator_success_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".numValidatorSuccess' )"
EOF
  read -r -d '' querySample[19] << EOF
  elrond_num_validator_failure_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".numValidatorFailure' )"
EOF
  read -r -d '' querySample[20] << EOF
  elrond_num_validator_ignored_signatures_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".numValidatorIgnoredSignatures' )"
EOF
  read -r -d '' querySample[21] << EOF
  elrond_total_num_leader_success_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".totalNumLeaderSuccess' )"
EOF
  read -r -d '' querySample[22] << EOF
  elrond_total_num_leader_failure_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".totalNumLeaderFailure' )"
EOF
  read -r -d '' querySample[23] << EOF
  elrond_total_num_validator_success_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".totalNumValidatorSuccess' )"
EOF
  read -r -d '' querySample[24] << EOF
  elrond_total_num_validator_failure_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".totalNumValidatorFailure' )"
EOF
  read -r -d '' querySample[25] << EOF
  elrond_total_num_validator_ignored_signatures_node0="\$( curl -sSL https://api.elrond.com/validator/statistics | jq '.data.statistics."'\$elrond_bls_node0'".totalNumValidatorIgnoredSignatures' )"
EOF

  cat << EOF >> $fileName

elrond_get() {

EOF
for i in "${!querySample[@]}"
do
    for n in $(seq 0 `expr $node - 1`)
    do
      echo "  ${querySample[$i]}" | sed "s/node0/node$n/g" | sed "s/localhost:8080/localhost:808$n/g" >> $fileName
    done
done

  cat << EOF >> $fileName

  # this should return:
  #  - 0 to send the data to netdata
  #  - 1 to report a failure to collect the data
  return 0
}

EOF

}

function staticElrondCheck () {
  cat <<EOF >> $fileName
# _check is called once, to find out if this chart should be enabled or not
elrond_check() {
  # this should return:
  #  - 0 to enable the chart
  #  - 1 to disable the chart

  # check something
  [ "\${elrond_magic_number}" != "12345" ] && error "manual configuration required: you have to set elrond_magic_number=\$elrond_magic_number in example.conf to start example chart." && return 1

  # check for required commands
  require_cmd curl || return 1
  require_cmd jq || return 1

  # check that we can collect data
  elrond_get || return 1

  return 0
}

EOF
}

function generateElrondCreate () {
  cat <<STATICEOF >> $fileName
# _create is called once, to create the charts
elrond_create() {
  # create the chart

  elrond_get || return 1

  cat << EOF
STATICEOF

declare -a blockCreate

read -r -d '' blockCreate[0] << EOF
CHART elrond.sync-node0 '' "\$elrond_node_type_node0/\$elrond_peer_type_node0 E:\$elrond_epoch_number_node0 S:\$elrond_shard_id_node0 P/V/N:\$elrond_connected_peers_node0/\$elrond_connected_validators_node0/\$elrond_connected_nodes_node0 R:\$elrond_tempRating_node0 \$elrond_app_version_node0" "Round" "Consensus round" elrond.round line \$((elrond_priority)) \$elrond_update_every
DIMENSION current 'Current' absolute 1 1
DIMENSION synced 'Synced' absolute 1 1
EOF
read -r -d '' blockCreate[1] << EOF
CHART elrond.validatorblocks-node0 '' "Validator blocks signed/accepted" "Blocks" "Validator blocks" elrond.vblocks area \$((elrond_priority + 2)) \$elrond_update_every
DIMENSION signedblocks 'Signed' absolute 1 1
DIMENSION signedaccepted 'Accepted' absolute 1 1
EOF
read -r -d '' blockCreate[2] << EOF
CHART elrond.leaderblocks-node0 '' "Leader blocks proposed/accepted" "Blocks" "Leader blocks" elrond.lblocks area \$((elrond_priority + 4)) \$elrond_update_every
DIMENSION leaderproposed 'Proposed' absolute 1 1
DIMENSION leaderaccepted 'Accepted' absolute 1 1
EOF
read -r -d '' blockCreate[3] << EOF
CHART elrond.rating-node0 '' "Current rating" "Rating" "Current rating" elrond.rating stacked \$((elrond_priority + 6)) \$elrond_update_every
DIMENSION rating 'Rating' absolute 1 1
EOF
read -r -d '' blockCreate[4] << EOF
CHART elrond.epoch-node0 '' "Current epch" "Epoch" "Current epoch" elrond.epoch stacked \$((elrond_priority + 8)) \$elrond_update_every
DIMENSION epoch 'Epoch' absolute 1 1
EOF
read -r -d '' blockCreate[5] << EOF
CHART elrond.peers-node0 '' "Connected peers" "Connected peers" "Peers" elrond.peers stacked \$((elrond_priority + 10)) \$elrond_update_every
DIMENSION peers 'Peers' absolute 1 1
EOF
read -r -d '' blockCreate[6] << EOF
CHART elrond.validators_nodes-node0 '' "Connected validators/nodes" "Validators/Nodes" "Validators/Nodes" elrond.vn area \$((elrond_priority + 12)) \$elrond_update_every
DIMENSION validators 'Validators' absolute 1 1
DIMENSION nodes 'Nodes' absolute 1 1
EOF
read -r -d '' blockCreate[7] << EOF
CHART elrond.num_leader-node0 '' "Num leader success/failure" "Leader success/failure" "Leader success/failure" elrond.lsf area \$((elrond_priority + 14)) \$elrond_update_every
DIMENSION leader_success 'Success' absolute 1 1
DIMENSION leader_failure 'Failure' absolute 1 1
EOF
read -r -d '' blockCreate[8] << EOF
CHART elrond.num_validator-node0 '' "Num validator success/failure" "Validator success/failure" "Validator success/failure" elrond.vsf area \$((elrond_priority + 16)) \$elrond_update_every
DIMENSION validator_success 'Success' absolute 1 1
DIMENSION validator_failure 'Failure' absolute 1 1
EOF
read -r -d '' blockCreate[9] << EOF
CHART elrond.ignored_signatures-node0 '' "Ignored signatures" "Signatures" "Ignored signatures" elrond.is stacked \$((elrond_priority + 18)) \$elrond_update_every
DIMENSION validator_ignored_signatures 'Ignored' absolute 1 1
EOF
read -r -d '' blockCreate[10] << EOF
CHART elrond.total_num_leader-node0 '' "Total num leader success/failure" "Leader success/failure" "Total leader success/failure" elrond.tlsf area \$((elrond_priority + 20)) \$elrond_update_every
DIMENSION total_leader_success 'Success' absolute 1 1
DIMENSION total_leader_failure 'Failure' absolute 1 1
EOF
read -r -d '' blockCreate[11] << EOF
CHART elrond.total_num_validator-node0 '' "Total num validator success/failure" "Validator success/failure" "Total vldt. success/failure" elrond.tvsf area \$((elrond_priority + 22)) \$elrond_update_every
DIMENSION total_validator_success 'Success' absolute 1 1
DIMENSION total_validator_failure 'Failure' absolute 1 1
EOF
read -r -d '' blockCreate[12] << EOF
CHART elrond.total_ignored_signatures-node0 '' "Total ignored signatures" "Signatures" "Total ignored signatures" elrond.tis stacked \$((elrond_priority + 24)) \$elrond_update_every
DIMENSION total_validator_ignored_signatures 'Ignored' absolute 1 1
EOF


declare -i priorityInc=0
for i in ${!blockCreate[@]}
do
  for n in $(seq 0 `expr $node -  1`)
  do
    if [[ $priorityInc -eq 0 ]]
    then
      echo "${blockCreate[$i]}" >> $fileName
      priorityInc+=1
    else
      echo "${blockCreate[$i]}" | sed "s/node0/node$n/g" | sed -E -r "s/\(\(elrond_priority.+\)/\(\(elrond_priority\ +\ $priorityInc\)\)/g" >> $fileName
      priorityInc+=1
    fi
  done
done

cat <<STATICEOF >> $fileName
EOF

  return 0
}

STATICEOF

}

function generateElrondUpdate () {
  cat <<STATICEOF >> $fileName
# _update is called continuously, to collect the values
elrond_update() {
  # the first argument to this function is the microseconds since last update
  # pass this parameter to the BEGIN statement (see bellow).

  elrond_get || return 1

  # write the result of the work.
  cat << VALUESEOF
STATICEOF

declare -a blockUpdate

read -r -d '' blockUpdate[0] << EOF
BEGIN elrond.sync-node0 \$1
SET current = \$elrond_current_round_node0
SET synced = \$elrond_synced_round_node0
END
EOF
read -r -d '' blockUpdate[1] << EOF
BEGIN elrond.validatorblocks-node0 \$1
SET signedblocks = \$elrond_count_consensus_node0
SET signedaccepted = \$elrond_count_consensus_accepted_blocks_node0
END
EOF
read -r -d '' blockUpdate[2] << EOF
BEGIN elrond.leaderblocks-node0 \$1
SET leaderproposed = \$elrond_count_leader_node0
SET leaderaccepted = \$elrond_count_accepted_blocks_node0
END
EOF
read -r -d '' blockUpdate[3] << EOF
BEGIN elrond.rating-node0 \$1
SET rating = \$elrond_tempRating_node0
END
EOF
read -r -d '' blockUpdate[4] << EOF
BEGIN elrond.epoch-node0 \$1
SET epoch = \$elrond_epoch_number_node0
END
EOF
read -r -d '' blockUpdate[5] << EOF
BEGIN elrond.peers-node0 \$1
SET peers = \$elrond_connected_peers_node0
END
EOF
read -r -d '' blockUpdate[6] << EOF
BEGIN elrond.validators_nodes-node0 \$1
SET validators = \$elrond_connected_validators_node0
SET nodes = \$elrond_connected_nodes_node0
END
EOF
read -r -d '' blockUpdate[7] << EOF
BEGIN elrond.num_leader-node0 \$1
SET leader_success = \$elrond_num_leader_success_node0
SET leader_failure = \$elrond_num_leader_failure_node0
END
EOF
read -r -d '' blockUpdate[8] << EOF
BEGIN elrond.num_validator-node0 \$1
SET validator_success = \$elrond_num_validator_success_node0
SET validator_failure = \$elrond_num_validator_failure_node0
END
EOF
read -r -d '' blockUpdate[9] << EOF
BEGIN elrond.ignored_signatures-node0 \$1
SET validator_ignored_signatures = \$elrond_num_validator_ignored_signatures_node0
END
EOF
read -r -d '' blockUpdate[10] << EOF
BEGIN elrond.total_num_leader-node0 \$1
SET total_leader_success = \$elrond_total_num_leader_success_node0
SET total_leader_failure = \$elrond_total_num_leader_failure_node0
END
EOF
read -r -d '' blockUpdate[11] << EOF
BEGIN elrond.total_num_validator-node0 \$1
SET total_validator_success = \$elrond_total_num_validator_success_node0
SET total_validator_failure = \$elrond_total_num_validator_failure_node0
END
EOF
read -r -d '' blockUpdate[12] << EOF
BEGIN elrond.total_ignored_signatures-node0 \$1
SET total_validator_ignored_signatures = \$elrond_total_num_validator_ignored_signatures_node0
END
EOF

for i in ${!blockUpdate[@]}
do
  for n in $(seq 0 `expr $node -  1`)
  do
      echo "${blockUpdate[$i]}" | sed "s/node0/node$n/g" >> $fileName
  done
done

  cat <<STATICEOF >> $fileName
VALUESEOF

  return 0
}
STATICEOF

}

generateVariable
generateQuery
staticElrondCheck
generateElrondCreate
generateElrondUpdate
