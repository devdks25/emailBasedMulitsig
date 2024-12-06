## Requirements
- Newer than or equal to `forge 0.2.0 (13497a5)`.

## Setup

```bash
yarn install
```

## Build and Deploy

If you wish to build and deploy the contracts yourself you can follow these steps.

### Set Up Environment Variables

Copy the example environment file and fill in the required variables:

```bash
cp .env.example .env
```

Edit the `.env` file and set the following variables:

- **CHAIN_ID**: Chain ID of the target network.
- **SIGNER**: ICP Canister signer that can update the DKIM registry. (Default: `0x6293a80bf4bd3fff995a0cab74cbf281d922da02`)
- **RPC_URL**: RPC URL for the target network.
- **PRIVATE_KEY**: Your private key for deployment (include the `0x` prefix).
- **ETHERSCAN_API_KEY**: (Optional) Etherscan API key for contract verification.

Make sure to replace `$RPC_URL` and `$ETHERSCAN_API_KEY` with your actual values.
Additionally, ensure that you have sufficient testnet ETH to pay gas fees in the account associated with your private key. 

### Deploy the Contracts

You can build and deploy the contract by running:

```bash
source .env
forge script script/DeployEmitEmailCommand.s.sol --rpc-url $RPC_URL --chain-id $CHAIN_ID --broadcast --etherscan-api-key $ETHERSCAN_API_KEY --verify -vvvv
```

You can see deployed contract addresses in the log of the script.

Example:
```
== Logs ==
  DKIM_DELAY: 0
  Initial owner: 0xcE025AAD11c61BE6Daec6E9f59cF010BBB531FF1
  UserOverrideableDKIMRegistry deployed at: 0x6adE531A50CaD1e95a739F1300eC2CBF687D61E3
  Verifier implementation deployed at: 0x8052122c782C414304583eD7dd996F7518d7E77C
  Verifier deployed at: 0xF5CD47823D3Dd35E9992Ab5853Db2FD1D77a96c2
  EmailAuth implementation deployed at: 0x16eEa4c77c5f20b57B4eEBcAdCfFedB39e87b5A6
  EmitEmailCommand deployed at: 0x87CC586F1150871ba7E14fd2AbAc93e31A1c9649
```

The address of `EmitEmailCommand` is used for the `<EMIT_EMAIL_COMMAND_ADDRESS>` input to the CLI provided in the `ts` direcotry. 