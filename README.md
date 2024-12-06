# Generic Relayer Template

This template provides an example Solidity contract leveraging [email-tx-builder](https://github.com/zkemail/email-tx-builder/tree/main) and a CLI to use our generic relayer with the example contract in `contracts` and `ts` direcotries, respectively. 

## Requirements
- Newer than or equal to `node 20.0.0`.
- Newer than or equal to `forge 0.2.0 (13497a5)`.

## Usage

To use this template, you first need to deploy an `EmitEmailCommand` contract following an instruction in [contracts/README.md](contracts/README.md).
You can then use the CLI as described in [ts/README.md](ts/README.md). 

