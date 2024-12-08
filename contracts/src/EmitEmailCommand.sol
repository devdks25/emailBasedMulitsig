// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@zk-email/email-tx-builder-contracts/src/EmailAuth.sol";
import "@openzeppelin/contracts/utils/Create2.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

// TODO: set owner role for setting threshold
/// @title Example contract that emits an event for the command in the given email.
contract EmitEmailCommand is ReentrancyGuard {
    struct TxApprovalMetaData {
        uint256 approvals;        // approvals gathered by the tx
        mapping (bytes32 publicKeyHash => bool) hasApproved;
        bytes32[] participatedPublicKeys;   // stored this to delete the mappping when tx is executed
    }

    address public verifierAddr;
    address public dkimAddr;
    address public emailAuthImplementationAddr;
    uint256 public thresholdApprovers;

    mapping (bytes32 tx => TxApprovalMetaData) txMapping;
    event UintCommand(address indexed emailAuthAddr, uint indexed command);
    event IntCommand(address indexed emailAuthAddr, int indexed command);
    event DecimalsCommand(address indexed emailAuthAddr, uint indexed command);
    event EthAddrCommand(
        address indexed emailAuthAddr,
        address indexed command
    );

    error FailedExecution(bytes reason); 

    constructor(
        address _verifierAddr,
        address _dkimAddr,
        address _emailAuthImplementationAddr,
        uint256 _thresholdApprovers
    ) {
        verifierAddr = _verifierAddr;
        dkimAddr = _dkimAddr;
        emailAuthImplementationAddr = _emailAuthImplementationAddr;
        thresholdApprovers = _thresholdApprovers;
    }

    /// Set `thresholdApprovers`
    /// @param _thresholdApprovers min no of approvals for tx to execute
    function setThresholdApprovers(uint256 _thresholdApprovers) external {
        thresholdApprovers = _thresholdApprovers;
    }

    /// @notice Returns the address of the verifier contract.
    /// @dev This function is virtual and can be overridden by inheriting contracts.
    /// @return address The address of the verifier contract.
    function verifier() public view virtual returns (address) {
        return verifierAddr;
    }

    /// @notice Returns the address of the DKIM contract.
    /// @dev This function is virtual and can be overridden by inheriting contracts.
    /// @return address The address of the DKIM contract.
    function dkim() public view virtual returns (address) {
        return dkimAddr;
    }

    /// @notice Returns the address of the email auth contract implementation.
    /// @dev This function is virtual and can be overridden by inheriting contracts.
    /// @return address The address of the email authentication contract implementation.
    function emailAuthImplementation() public view virtual returns (address) {
        return emailAuthImplementationAddr;
    }

    /// @notice Computes the address for email auth contract using the CREATE2 opcode.
    /// @dev This function utilizes the `Create2` library to compute the address. The computation uses a provided account address to be recovered, account salt,
    /// and the hash of the encoded ERC1967Proxy creation code concatenated with the encoded email auth contract implementation
    /// address and the initialization call data. This ensures that the computed address is deterministic and unique per account salt.
    /// @param owner The address of the owner of the EmailAuth proxy.
    /// @param accountSalt A bytes32 salt value defined as a hash of the guardian's email address and an account code. This is assumed to be unique to a pair of the guardian's email address and the wallet address to be recovered.
    /// @return address The computed address.
    function computeEmailAuthAddress(
        address owner,
        bytes32 accountSalt
    ) public view returns (address) {
        return
            Create2.computeAddress(
                accountSalt,
                keccak256(
                    abi.encodePacked(
                        type(ERC1967Proxy).creationCode,
                        abi.encode(
                            emailAuthImplementation(),
                            abi.encodeCall(
                                EmailAuth.initialize,
                                (owner, accountSalt, address(this))
                            )
                        )
                    )
                )
            );
    }

    /// @notice Deploys a new proxy contract for email authentication.
    /// @dev This function uses the CREATE2 opcode to deploy a new ERC1967Proxy contract with a deterministic address.
    /// @param owner The address of the owner of the EmailAuth proxy.
    /// @param accountSalt A bytes32 salt value used to ensure the uniqueness of the deployed proxy address.
    /// @return address The address of the newly deployed proxy contract.
    function deployEmailAuthProxy(
        address owner,
        bytes32 accountSalt
    ) internal returns (address) {
        ERC1967Proxy proxy = new ERC1967Proxy{salt: accountSalt}(
            emailAuthImplementation(),
            abi.encodeCall(
                EmailAuth.initialize,
                (owner, accountSalt, address(this))
            )
        );
        return address(proxy);
    }

    /// @notice Calculates a unique command template ID for template provided by this contract.
    /// @dev Encodes the email account recovery version ID, "EXAMPLE", and the template index,
    /// then uses keccak256 to hash these values into a uint ID.
    /// @param templateIdx The index of the command template.
    /// @return uint The computed uint ID.
    function computeTemplateId(uint templateIdx) public pure returns (uint) {
        return uint256(keccak256(abi.encode("EXAMPLE", templateIdx)));
    }

    /// @notice Returns a two-dimensional array of strings representing the command templates.
    /// @return string[][] A two-dimensional array of strings, where each inner array represents a set of fixed strings and matchers for a command template.
    function commandTemplates() public pure returns (string[][] memory) {
        string[][] memory templates = new string[][](6);
        templates[0] = new string[](4);
        templates[0][0] = "Execute";
        templates[0][1] = "{calldata}";
        templates[0][2] = "to";
        templates[0][3] = "{ethAddr}";

        templates[1] = new string[](5);
        templates[1][0] = "Approve";
        templates[1][1] = "{ethAddr}";
        templates[1][2] = "{uint}";
        templates[1][3] = "spender";
        templates[1][4] = "{ethAddr}";

        templates[2] = new string[](5);
        templates[2][0] = "Send";
        templates[2][1] = "{ethAddr}";
        templates[2][2] = "{uint}";
        templates[2][3] = "to";
        templates[2][4] = "{ethAddr}";

        templates[3] = new string[](6);
        templates[3][0] = "Approval";
        templates[3][1] = "To";
        templates[3][2] = "Execute";
        templates[3][3] = "{calldata}";
        templates[3][4] = "Target";
        templates[3][5] = "{ethAddr}";

        templates[4] = new string[](7);
        templates[4][0] = "Approval";
        templates[4][1] = "To";
        templates[4][2] = "Approve";
        templates[4][3] = "{ethAddr}";
        templates[4][4] = "{uint}";
        templates[4][5] = "spender";
        templates[4][6] = "{ethAddr}";

        templates[5] = new string[](7);
        templates[5][0] = "Approval";
        templates[5][1] = "To";
        templates[5][2] = "Send";
        templates[5][3] = "{ethAddr}";
        templates[5][4] = "{uint}";
        templates[5][5] = "to";
        templates[5][6] = "{ethAddr}";

        return templates;
    }

    /// Performs the email data verification and executes the given calldata
    /// @param emailAuthMsg Email auth msg 
    /// @param owner owner of the emailAuth proxy contract
    /// @param templateIdx command template index
    function emitEmailCommand(
        EmailAuthMsg memory emailAuthMsg,
        address owner,
        uint templateIdx
    ) public {
        address emailAuthAddr = computeEmailAuthAddress(
            owner,
            emailAuthMsg.proof.accountSalt
        );
        uint templateId = computeTemplateId(templateIdx);
        require(templateId == emailAuthMsg.templateId, "invalid template id");

        EmailAuth emailAuth;
        if (emailAuthAddr.code.length == 0) {
            require(
                emailAuthMsg.proof.isCodeExist == true,
                "isCodeExist must be true for the first email"
            );
            address proxyAddress = deployEmailAuthProxy(
                owner,
                emailAuthMsg.proof.accountSalt
            );
            require(
                proxyAddress == emailAuthAddr,
                "proxy address does not match with emailAuthAddr"
            );
            emailAuth = EmailAuth(proxyAddress);
            emailAuth.initDKIMRegistry(dkim());
            emailAuth.initVerifier(verifier());
            string[][] memory templates = commandTemplates();
            for (uint idx = 0; idx < templates.length; idx++) {
                emailAuth.insertCommandTemplate(
                    computeTemplateId(idx),
                    templates[idx]
                );
            }
        } else {
            emailAuth = EmailAuth(payable(address(emailAuthAddr)));
            require(
                emailAuth.controller() == address(this),
                "invalid controller"
            );
        }
        emailAuth.authEmail(emailAuthMsg);
        _executeCommand(emailAuthMsg.proof.publicKeyHash, emailAuthMsg.commandParams, templateIdx);
    }

    function _executeCommand(
        bytes32 publicKeyHash,
        bytes[] memory commandParams,
        uint templateIdx
    ) internal {
        if (templateIdx == 0) {
            bytes memory callData = commandParams[0];
            address targetAddr = abi.decode(commandParams[1], (address));
            (bool success, bytes memory result) = targetAddr.call(callData);
            if (!success) revert FailedExecution(result);
        } else if (templateIdx == 1) {
            return;
            address token = abi.decode(commandParams[0], (address));
            uint256 amount = abi.decode(commandParams[1], (uint256));
            address spender = abi.decode(commandParams[2], (address));
            IERC20(token).approve(spender, amount);
        } else if (templateIdx == 2) {
            address token = abi.decode(commandParams[0], (address));
            uint256 amount = abi.decode(commandParams[1], (uint256));
            address to = abi.decode(commandParams[2], (address));
            IERC20(token).transfer(to, amount);
        } else if (templateIdx == 3) {
            bytes memory callData = commandParams[0];
            address targetAddr = abi.decode(commandParams[1], (address));
            bytes32 txIndentifier = getTxIdentifier(targetAddr, callData);
            updateTxMetadata(targetAddr, callData, publicKeyHash);
        } else if (templateIdx == 4) {
            address token = abi.decode(commandParams[0], (address));
            uint256 amount = abi.decode(commandParams[1], (uint256));
            address spender = abi.decode(commandParams[2], (address));
            bytes memory callData = abi.encodeCall(IERC20.approve, (spender, amount));
            updateTxMetadata(token, callData, publicKeyHash);
        } else if (templateIdx == 5) {
            address token = abi.decode(commandParams[0], (address));
            uint256 amount = abi.decode(commandParams[1], (uint256));
            address to = abi.decode(commandParams[2], (address));
            bytes memory callData = abi.encodeCall(IERC20.transfer, (to, amount));
            updateTxMetadata(token, callData, publicKeyHash);
        } else {
            revert("invalid templateIdx");
        }
    }

    function getTxIdentifier(address target, bytes memory callData) internal returns (bytes32) {
        return keccak256(abi.encode(target, callData));
    }

    function updateTxMetadata(address target, bytes memory callData, bytes32 publicKeyHash) internal {
        bytes32 txIndentifier = getTxIdentifier(target, callData);
        if (!txMapping[txIndentifier].hasApproved[publicKeyHash]) {
            txMapping[txIndentifier].hasApproved[publicKeyHash] = true;
            txMapping[txIndentifier].participatedPublicKeys.push(publicKeyHash);
            txMapping[txIndentifier].approvals++;
            if (txMapping[txIndentifier].approvals == thresholdApprovers) { // threshold reached
                (bool success, bytes memory result) = target.call(callData);
                if (!success) revert FailedExecution(result);
                // remove the tx metadata
                for (uint i = 0; i < txMapping[txIndentifier].approvals; i++) {
                    bytes32 keyHash = txMapping[txIndentifier].participatedPublicKeys[i];
                    delete txMapping[txIndentifier].hasApproved[publicKeyHash];
                }
                delete txMapping[txIndentifier];
            }
        }
    }
}
