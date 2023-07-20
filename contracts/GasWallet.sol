pragma solidity ^0.8.19;

import "./Vault.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";



contract GasWallet {
    event Trade(Vault.Signature signature, Vault.UniTrade trade, uint256[] amountsOut);

    using SafeERC20 for IERC20;

    address immutable public vault;

    constructor(address _vault) {
        vault = _vault;
    }

    function goTrade(Vault.Signature calldata signature, Vault.UniTrade calldata trade) external {
        Vault(vault).getTokens(signature, trade);
        IERC20 token = IERC20(trade.path[0]);

        if (token.allowance(address(this), trade.router) == 0) {
            token.safeApprove(trade.router, type(uint256).max);
        }

        uint256[] memory amounts = IUniswapV2Router02(trade.router).swapExactTokensForTokens(
            trade.amountIn,
            trade.amountOutMin,
            trade.path,
            trade.to,
            trade.deadline
        );
        emit Trade(signature, trade, amounts);
    }
}
