// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ierc20token.sol";
import "./ICollateralLoan.sol";
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

contract CollateralLoan is ICollateralLoan {
    bool public _isFlashLoanAttackPossible;

    function _getPriceOnExchange(address factory, address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) private view returns (uint) {
        address pairAddress = IUniswapV2Factory(factory).getPair(tokenToBorrow, tokenAsCollateral);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        
        address token0 = pair.token0();
        uint reservesTokenToBorrow = tokenToBorrow == token0 ? Res0 : Res1;
        uint reservesTokenAsCollateral = tokenToBorrow == token0 ? Res1 : Res0;
        
        return (collateralAmount*reservesTokenToBorrow)/reservesTokenAsCollateral;
    }
    
    function _getAveragePriceFromMultipleExchanges(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) private view returns (uint) {
        uint amountOfTokenToBorrowOnUniswap = _getPriceOnExchange(0xeB8749f7394AfE2A5cf44251d196763C1E2aC5Cb, tokenToBorrow, tokenAsCollateral, collateralAmount);
        uint amountOfTokenToBorrowOnSushiswap = _getPriceOnExchange(0xa04AFAf07bFb9E4E14a84fFC103490ABd7B9B927, tokenToBorrow, tokenAsCollateral, collateralAmount);
        
        // averaging assert prices on multiple exchanges
        return amountOfTokenToBorrowOnUniswap / 100 * 10 + amountOfTokenToBorrowOnSushiswap / 100 * 90;
    }

    function loan(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) external override {
        address borrower = msg.sender;
        address lender = address(this);
        
        uint amountOfTokenToBorrow;
        if (_isFlashLoanAttackPossible) {
            amountOfTokenToBorrow = _getPriceOnExchange(0xeB8749f7394AfE2A5cf44251d196763C1E2aC5Cb, tokenToBorrow, tokenAsCollateral, collateralAmount);
        } else {
            amountOfTokenToBorrow = _getAveragePriceFromMultipleExchanges(tokenToBorrow, tokenAsCollateral, collateralAmount);
        }
        
        require(IERC20(tokenToBorrow).transfer(borrower, amountOfTokenToBorrow),"token to borrow: Transfer failed");
        require(IERC20(tokenAsCollateral).transferFrom(borrower, lender, collateralAmount),"tokenAsCollateral Transfer failed");
    }
    
     function setIsFlashLoanAttackPossible(bool isFlashLoanAttackPossible) external {
        _isFlashLoanAttackPossible = isFlashLoanAttackPossible;
    }
    
}