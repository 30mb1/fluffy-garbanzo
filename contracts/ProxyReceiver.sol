// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract ProxyReceiver {
    using SafeERC20 for IERC20;

    address immutable public vault;

    constructor(address _vault) {
        vault = _vault;
    }


    function withdraw(IERC20[] calldata tokens) external {
        for (uint i = 0; i < tokens.length; i++) {
            uint balance = tokens[i].balanceOf(address(this));
            tokens[i].safeTransfer(vault, balance);
        }
    }
}
