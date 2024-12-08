// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Mintable is ERC20 {
    constructor() ERC20("TEST_TOKEN", "TT") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}