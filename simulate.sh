source .env

RESCUE_TERMINAL_ADDRESS="0x022640ea204c5919903bea5c799e215424236cc8"

CURRENT_TERMINAL_ADDRESS="0x1d9619E10086FdC1065B114298384aAe3F680CC0"
ARTIZEN_PROJECT_ID=587

cast send --rpc-url=$RPC_TENDERLY_MAINNET_FORK --unlocked --from $RENE_ADDRESS $CURRENT_TERMINAL_ADDRESS "migrate(uint256,address)" $ARTIZEN_PROJECT_ID $RESCUE_TERMINAL_ADDRESS

cast send --rpc-url=$RPC_TENDERLY_MAINNET_FORK --unlocked --from $RENE_ADDRESS $RESCUE_TERMINAL_ADDRESS "distributePayoutsOf(uint256,uint256,uint256,address,uint256,bytes)" $ARTIZEN_PROJECT_ID 0 0 0x0000000000000000000000000000000000000000 0 0x00
