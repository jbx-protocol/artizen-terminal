#!/bin/bash

source .env

if ! command -v forge &> /dev/null
then
    echo "Could not find foundry."
    echo "Please refer to the README.md for installation instructions."
    exit
fi

help_string="Available commands:
  help, -h, --help           - Show this help message
  deploy:ethereum-mainnet    - Deploy to Ethereum mainnet
  deploy:ethereum-goerli     - Deploy to Ethereum Goerli testnet"

if [ $# -eq 0 ]
then
  echo "$help_string"
  exit
fi

case "$1" in
  "help") echo "$help_string" ;;
  "-h") echo "$help_string" ;;
  "--help") echo "$help_string" ;;
  "deploy:ethereum-mainnet") source .env && forge script Deploy --chain-id 1 --rpc-url $RPC_ETHEREUM_MAINNET --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY --interactives 1 --sender $SENDER_ETHEREUM_MAINNET -vvv ;;
  "deploy:ethereum-goerli") source .env && forge script Deploy --chain-id 5 --rpc-url $RPC_ETHEREUM_GOERLI --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY --interactives 1 --sender $SENDER_ETHEREUM_GOERLI -vvv ;;
  *) echo "Invalid command: $1" ;;
esac