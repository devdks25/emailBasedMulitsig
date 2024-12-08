# Generic Relayer Template

This template provides an example Solidity contract leveraging [email-tx-builder](https://github.com/zkemail/email-tx-builder/tree/main) and a CLI to use our generic relayer with the example contract in `contracts` and `ts` direcotries, respectively. 

## Requirements
- Newer than or equal to `node 20.0.0`.
- Newer than or equal to `forge 0.2.0 (13497a5)`.

## Usage

To use this template, you first need to deploy an `EmitEmailCommand` contract following an instruction in [contracts/README.md](contracts/README.md).

You can then use the CLI as described in [ts/README.md](ts/README.md). 

## ChangeSet
-  The app can act as a multiSig wallet or a EOA wallet based on the command template requested.
-  Wallet functionalities:
    -   Approve any ERC20 token transfer from the wallet to any EOA/Smart contract.
    -   Send any ERC20 token from the wallet to any EOA/Smart contract.
    -   Execute any raw calldata on any target smart contract.

-  MultiSig:
    -   A threshold number of approvers are requires to approve a proposed transaction.
    -   This threshold can be changed anytime by contract owner.
    -   Based on the command templates a multisig transaction request can be initiated.
    -   Once a threshold number of approvers have approved the tx, it's executed.