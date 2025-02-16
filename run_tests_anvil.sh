#!/bin/bash

is_anvil_ready() {
  cast blockNumber --rpc-url http://127.0.0.1:8545 > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        return 1
    else
        return 0
    fi

}

anvil --port 8545 > /dev/null 2>&1 &
ANVIL_PID=$! # Save to kill after 

printf "Waiting for Anvil... /"
while ! is_anvil_ready; do
    printf "\rWaiting for Anvil... \\"
    sleep 0.5
    printf "\rWaiting for Anvil... /"
    sleep 0.5
done
printf "\nAnvil is ready\n"
printf "Beginning tests against the RPC URL at 127.0.0.1:8545\n"

forge test --rpc-url 127.0.0.1:8545
forge_exit_code=$?


kill $ANVIL_PID
exit $forge_exit_code