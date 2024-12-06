This is a CLI to use a generic relayer with an `EmitEmailCommand` example contract.

## Requirements
- Newer than or equal to `node 20.0.0`.

## Setup

```bash
yarn install
```

## How to use
Before using the CLI, you need to prepare 1) a private key to broadcast transactions, 2) the relayer's URL, and 3) addresses of `EmitEmailCommand` and DKIM registry contracts.
The first two values should be set in the `.env` file, as demonstrated in the `.env.example` file.
The contract addresses can be obtained from the log of the `DeployEmitEmailCommand.s.sol` script as described in [contracts/README.md](../contracts/README.md).

You can use the CLI by the below command format:

`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx <TEMPLATE_IDX> --command-value <COMMAND_VALUE> --subject <SUBJECT> --body <BODY>`

Each argument is defined as follows:
- `EMIT_EMAIL_COMMAND_ADDRESS`: an Ethereum address of the `EmitEmailCommand` command.
- `ACCOUNT_CODE`: an account code for your `EmailAuth` contract, e.g., "0x22a2d51a892f866cf3c6cc4e138ba87a8a5059a1d80dea5b8ee8232034a105b7".
- `EMAIL_ADDRESS`: an email address for your `EmailAuth` contract.
- `OWNER_ADDRESS_OF_EMAIL_AUTH`: an Ethereum address of the owner EOA/contract of your `EmailAuth` contract.
- `TEMPLATE_IDX`: the index of a command template defined in the `EmitEmailCommand` contract, in paritcular 0 for a string command, 1 for an uint command, 2 for an int command, 3 for a decimal command, and 4 for an Ethereum address command.
- `COMMAND_VALUE` the value of a placeholder in the command template selected by `TEMPLATE_IDX`.
- `SUBJECT`: a string in the subject of the email.
- `BODY`: a string in the body of the email.

### Examples
- Emit `{string}`
`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx 0 --command-value "Hello" --subject "Emit a string Hello" --body "Emit a string Hello"`

- Emit `{uint}`
`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx 1 --command-value "123" --subject "Emit an uint 123" --body "Emit an uint 123"`

- Emit `{int}`
`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx 2 --command-value "-123" --subject "Emit an int -123" --body "Emit an int -123"`

- Emit `{decimals}`
`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx 3 --command-value "1.23" --subject "Emit decimals 1.23" --body "Emit decimals 1.23"`

- Emit `{ethAddr}`
`npx ts-node src/cli.ts --emit-email-command-addr <EMIT_EMAIL_COMMAND_ADDRESS> --account-code <ACCOUNT_CODE> --email-addr <EMAIL_ADDRESS> --owner-addr <OWNER_ADDRESS_OF_EMAIL_AUTH> --template-idx 4 --command-value "0x6956856464EaA434f22B42642e9089fF8e5C9cE9" --subject "Emit an ethereum address 0x6956856464EaA434f22B42642e9089fF8e5C9cE9" --body "Emit an ethereum address 0x6956856464EaA434f22B42642e9089fF8e5C9cE9"`