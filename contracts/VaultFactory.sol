// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Vault.sol";

contract VaultFactory {
    event NewVault(address vault);

    address public immutable owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deployVault(address signer) external returns (address) {
        Vault vault = new Vault(owner, signer);
        emit NewVault(address(vault));
        return address(vault);
    }
}
