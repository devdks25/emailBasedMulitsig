// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "forge-std/Test.sol";
import "../src/EmitEmailCommand.sol";
import "./utils/TestCall.sol";
import "./utils/ERC20Mintable.sol";

contract EmitEmailCommandTest is Test, EmitEmailCommand {

    ERC20Mintable erc20Mintable;

    constructor() EmitEmailCommand(address(0),address(0),address(0), 2) {}
    function setUp() public {
        erc20Mintable = new ERC20Mintable();
    }

    function test_contractCall() public {
        address target = address(new TestCall());
        bytes[] memory command = new bytes[](2);
        command[0] = abi.encodeCall(TestCall.doNothing, ());
        command[1] = abi.encode(target);
        _executeCommand(bytes32(uint256(0)), command, uint256(0));
    }

    function test_approve_token_allowance(uint256 amount) public {
        vm.assume(amount > 0);
        address spender = vm.randomAddress();
        erc20Mintable.mint(address(this), amount);
        bytes[] memory command = new bytes[](3);
        command[0] = abi.encode(address(erc20Mintable));
        command[1] = abi.encode(amount);
        command[2] = abi.encode(spender);
        _executeCommand(bytes32(uint256(0)), command, uint256(1));
        assertEq(erc20Mintable.allowance(address(this), spender), amount);
    }

    function test_send_token(uint256 amount) public {
        vm.assume(amount > 0);
        address spender = vm.randomAddress();
        erc20Mintable.mint(address(this), amount);
        bytes[] memory command = new bytes[](3);
        command[0] = abi.encode(address(erc20Mintable));
        command[1] = abi.encode(amount);
        command[2] = abi.encode(spender);
        _executeCommand(bytes32(uint256(0)), command, uint256(2));
        assertEq(erc20Mintable.balanceOf(spender), amount);
    }

    function test_contractCallMulitsig() public {
        address target = address(new TestCall());
        bytes[] memory command = new bytes[](2);
        command[0] = abi.encodeCall(TestCall.doNothing, ());
        command[1] = abi.encode(target);
        bytes32 keyHash1 = bytes32(vm.randomUint());
        bytes32 keyHash2 = bytes32(vm.randomUint());
        _executeCommand(keyHash1, command, uint256(3));
        vm.expectEmit();
        emit TestCall.Called();
        _executeCommand(keyHash2, command, uint256(3));
    }

    function test_approve_token_allowanceMultisig(uint256 amount) public {
        vm.assume(amount > 0);
        address spender = vm.randomAddress();
        erc20Mintable.mint(address(this), amount);
        bytes[] memory command = new bytes[](3);
        command[0] = abi.encode(address(erc20Mintable));
        command[1] = abi.encode(amount);
        command[2] = abi.encode(spender);
        bytes32 keyHash1 = bytes32(vm.randomUint());
        bytes32 keyHash2 = bytes32(vm.randomUint());
        _executeCommand(keyHash1, command, uint256(4));
        assertEq(erc20Mintable.allowance(address(this), spender), 0);
        _executeCommand(keyHash2, command, uint256(4));
        assertEq(erc20Mintable.allowance(address(this), spender), amount);
    }

    function test_send_token_allowanceMultisig(uint256 amount) public {
        vm.assume(amount > 0);
        address spender = vm.randomAddress();
        erc20Mintable.mint(address(this), amount);
        bytes[] memory command = new bytes[](3);
        command[0] = abi.encode(address(erc20Mintable));
        command[1] = abi.encode(amount);
        command[2] = abi.encode(spender);
        bytes32 keyHash1 = bytes32(vm.randomUint());
        bytes32 keyHash2 = bytes32(vm.randomUint());
        _executeCommand(keyHash1, command, uint256(5));
        assertEq(erc20Mintable.balanceOf(spender), 0);
        _executeCommand(keyHash2, command, uint256(5));
        assertEq(erc20Mintable.balanceOf(spender), amount);
    }
}