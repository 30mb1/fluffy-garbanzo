// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Vault.sol";

contract VaultFactory {
    event NewVault(address vault);

    address public immutable owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function deployVault(address _signer, address _owner) external returns (address) {
        require (msg.sender == owner, "VaultFactory::deployVault:: not owner");

        Vault vault = new Vault(_owner, _signer);
        emit NewVault(address(vault));
        return address(vault);
    }
}
