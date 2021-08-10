// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Silver is ERC20 {
    constructor() ERC20("Silver", "Silver") {
        _mint(msg.sender, 100000000 * 10**18);
    }
}
