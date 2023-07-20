// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./GasWallet.sol";
import "./ProxyReceiver.sol";


contract Vault {
    event NewGasWallet(address gasWallet);
    event NewProxyReceiver(address proxyReceiver);
    event TokensRedeemed(address token, address wallet, uint amount);

    using SafeERC20 for IERC20;

    struct UniTrade {
        address router;
        uint amountIn;
        uint amountOutMin;
        address[] path;
        address to;
        uint deadline;
    }

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    // this address can withdraw balance
    address immutable public owner;
    address immutable public signer;
    uint32 public nonce;

    constructor(address _owner, address _signer) {
        owner = _owner;
        signer = _signer;
    }

    function deployGasWallet() external {
        emit NewGasWallet(address(new GasWallet(address(this))));
    }

    function deployProxyReceiver() external {
        emit NewProxyReceiver(address(new ProxyReceiver(address(this))));
    }

    function withdraw(IERC20[] calldata tokens) external {
        require (msg.sender == owner, "Vault::withdraw:: not owner");

        for (uint i = 0; i < tokens.length; i++) {
            uint balance = tokens[i].balanceOf(address(this));
            tokens[i].safeTransfer(msg.sender, balance);
        }
    }

    function checkSign(Signature memory signature) public view returns (bool) {
        bytes32 ethSignedMessageHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", nonce)
        );
        address recoveredAddress = ecrecover(ethSignedMessageHash, signature.v, signature.r, signature.s);
        return recoveredAddress == signer;
    }

    function getTokens(Signature calldata signature, UniTrade calldata trade) external {
        require (checkSign(signature), "Vault::getTokens:: invalid signature");
        nonce += 1;

        IERC20 tokenSpent = IERC20(trade.path[0]);
        uint amountSpent = trade.amountIn;

        tokenSpent.safeTransfer(msg.sender, amountSpent);
        emit TokensRedeemed(address(tokenSpent), msg.sender, amountSpent);
    }
}
