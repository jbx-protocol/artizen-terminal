import './style.css'
import { createConfig, http, connect, switchChain, writeContract, waitForTransactionReceipt } from '@wagmi/core'
import { mainnet } from '@wagmi/core/chains'
import { injected } from '@wagmi/connectors'
import { parseAbi } from 'viem'

const currentTerminal = `0x1d9619E10086FdC1065B114298384aAe3F680CC0`
const artizenProjectId = 587n;
const recoveryTerminal = `0x0000000000000000000000000000000000000000`

document.querySelector('#app').innerHTML = `
  <h1>Artizen Recovery</h1>
  <div class="card">
    <button id="connect">1. Connect</button>
    <button id="migrate">2. Migrate</button>
    <button id="payout">3. Payout</button>
  </div>
  <p id="statusText"></p>
`

const config = createConfig({
  chains: [mainnet],
  connectors: [injected()],
  transports: {
    [mainnet.id]: http(),
  },
})

const connectButton = document.getElementById("connect")
const statusText = document.getElementById("statusText")

let result;
connectButton.onclick = async () => {
  connectButton.innerText = "Connecting..."
  result = await connect(config, {connector: injected()})
  connectButton.innerText = "Connected"
  statusText.innerText += `\nConnected to ${result.accounts[0]}.`
  
  if (result.chainId !== 1) {
    statusText.innerText += `\nWallet connected to wrong network. Switching to Ethereum mainnet...`
    await switchChain(config, { chainId: 1 })
    statusText.innerText += `\nSwitched to Ethereum mainnet.`
  }
}

const migrateButton = document.getElementById("migrate")
migrateButton.onclick = async () => {
  if (!result.accounts[0]) {
    statusText.innerText += `\nConnect wallet first.`
    return
  }

  statusText.innerText += `\nWaiting for migration transaction approval...`
  const migrateTxHash = await writeContract(config, {
    abi: parseAbi(["function migrate(uint256,address) returns (uint256)"]),
    address: currentTerminal,
    functionName: "migrate",
    args: [artizenProjectId, recoveryTerminal],
  })
  statusText.innerText += `\nMigrating...`
  const migrateReceipt = await waitForTransactionReceipt(config, {
    hash: migrateTxHash
  })
  
  statusText.innerText += `\nMigration successful. Hash: ${migrateReceipt.transactionHash}`
}

const payoutButton = document.getElementById("payout")
payoutButton.onclick = async () => {
  if (!result.accounts[0]) {
    statusText.innerText += `\nConnect wallet first.`
    return
  }
  
  statusText.innerText += `\nWaiting for payout transaction approval...`
  const payoutTxHash = await writeContract(config, {
    abi: parseAbi(["function distributePayoutsOf(uint256,uint256,uint256,address,uint256,bytes) returns (uint256)"]),
    address: recoveryTerminal,
    functionName: "distributePayoutsOf",
    args: [artizenProjectId, 0n, 0n, "0x0000000000000000000000000000000000000000", 0n, "0x00"],
  })
  statusText.innerText += `\nSending payouts...`
  const payoutReceipt = await waitForTransactionReceipt(config, {
    hash: payoutTxHash
  })
  statusText.innerText += `\nPayout successful. Hash: ${payoutReceipt.transactionHash}`
}
