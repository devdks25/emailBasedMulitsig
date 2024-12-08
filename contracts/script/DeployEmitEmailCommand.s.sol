// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";

import "@zk-email/email-tx-builder-contracts/src/utils/Verifier.sol";
import "@zk-email/email-tx-builder-contracts/src/utils/Groth16Verifier.sol";
import "@zk-email/contracts/UserOverrideableDKIMRegistry.sol";
import "@zk-email/email-tx-builder-contracts/src/EmailAuth.sol";
import "../src/EmitEmailCommand.sol";
import "../test/utils/ERC20Mintable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract Deploy is Script {
    UserOverrideableDKIMRegistry dkimImpl;
    UserOverrideableDKIMRegistry dkim;
    Verifier verifierImpl;
    Verifier verifier;
    EmailAuth emailAuthImpl;
    EmitEmailCommand emitEmailCommand;
    ERC20Mintable erc20;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        if (deployerPrivateKey == 0) {
            console.log("PRIVATE_KEY env var not set");
            return;
        }
        address signer = vm.envAddress("SIGNER");
        if (signer == address(0)) {
            console.log("SIGNER env var not set");
            return;
        }
        uint256 timeDelay = vm.envOr("DKIM_DELAY", uint256(0));
        console.log("DKIM_DELAY: %s", timeDelay);
        vm.startBroadcast(deployerPrivateKey);
        address initialOwner = vm.addr(deployerPrivateKey);
        console.log("Initial owner: %s", vm.toString(initialOwner));
        // Deploy Useroverridable DKIM registry
        {
            dkimImpl = new UserOverrideableDKIMRegistry();
            address dkimProxyAddress = address(
                new ERC1967Proxy(
                    address(dkimImpl),
                    abi.encodeCall(
                        UserOverrideableDKIMRegistry.initialize,
                        (initialOwner, signer, timeDelay)
                    )
                )
            );
            dkim = UserOverrideableDKIMRegistry(dkimProxyAddress);
            console.log(
                "UserOverrideableDKIMRegistry deployed at: %s",
                address(dkim)
            );
        }
        // Deploy Verifier
        {
            verifierImpl = new Verifier();
            console.log(
                "Verifier implementation deployed at: %s",
                address(verifierImpl)
            );
            Groth16Verifier groth16Verifier = new Groth16Verifier();
            ERC1967Proxy verifierProxy = new ERC1967Proxy(
                address(verifierImpl),
                abi.encodeCall(
                    verifierImpl.initialize,
                    (initialOwner, address(groth16Verifier))
                )
            );
            verifier = Verifier(address(verifierProxy));
            console.log("Verifier deployed at: %s", address(verifier));
        }
        // Deploy EmailAuth Implementation
        {
            emailAuthImpl = new EmailAuth();
            console.log(
                "EmailAuth implementation deployed at: %s",
                address(emailAuthImpl)
            );
        }
        // // Deploy EmitEmailCommand
        {
            emitEmailCommand = new EmitEmailCommand(
                address(verifier),
                address(dkim),
                address(emailAuthImpl),
                2
            );
            console.log(
                "EmitEmailCommand deployed at: %s",
                address(emitEmailCommand)
            );
        }
        // Deploy erc20Mintable for testing
        {
            erc20 = new ERC20Mintable();
            console.log(
                "erc20Mintable deployed at: %s",
                address(erc20)
            );
            erc20.mint(address(emitEmailCommand), 1e10);
            console.log(
                "minted 1e10 tokens to EmitEmailCommand: %s",
                address(emitEmailCommand)
            );
        }
        vm.stopBroadcast();
    }
}
