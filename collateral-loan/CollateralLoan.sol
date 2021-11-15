// SPDX-License-Identifier: UZH
pragma solidity ^0.8.0;

import "./ierc20token.sol";
import "./ICollateralLoan.sol";
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

contract CollateralLoan is ICollateralLoan {

    function _getPriceFromUniswap(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) private view returns (uint) {
        address pairAddress = IUniswapV2Factory(0xeB8749f7394AfE2A5cf44251d196763C1E2aC5Cb).getPair(tokenToBorrow, tokenAsCollateral);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        
        address token0 = pair.token0();
        uint reservesTokenToBorrow = tokenToBorrow == token0 ? Res0 : Res1;
        uint reservesTokenAsCollateral = tokenToBorrow == token0 ? Res1 : Res0;
        
        return (collateralAmount*reservesTokenToBorrow)/reservesTokenAsCollateral;
    }

    function loan(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) external override {
        address borrower = msg.sender;
        address lender = address(this);
        uint amountOfTokenToBorrow = _getPriceFromUniswap(tokenToBorrow, tokenAsCollateral, collateralAmount);
        require(IERC20(tokenToBorrow).transfer(borrower, amountOfTokenToBorrow),"token to borrow: Transfer failed");
        require(IERC20(tokenAsCollateral).transferFrom(borrower, lender, collateralAmount),"tokenAsCollateral Transfer failed");
    }
    
    
    
    /*
    
    // uniswap: flash loan attack
    function _getPriceFromUniswap(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) private returns (uint) {
        address pairAddress = IUniswapV2Factory(0xeB8749f7394AfE2A5cf44251d196763C1E2aC5Cb).getPair(tokenToBorrow, tokenAsCollateral);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        token0 = pair.token0();
        reservesTokenToBorrow = tokenToBorrow == token0 ? Res0 : Res1;
        reservesTokenAsCollateral = tokenToBorrow == token0 ? Res1 : Res0;
        
        

        // decimals
        // reservesTokenToBorrow = reservesTokenToBorrow*(10**IERC20(tokenAsCollateral).decimals());
        
        // tokenAsCollateral = DAI, collateralAmount = 10
        // tokenToBorrow = ETH, amountOfTokenToBorrow = X
        // 10 * Price DAi == X * Price of ETH
        // Dai/ETH -> 1 DAI / 5 ETH -> Dai/ETH = 5 (reseresTokenAsCollateral/reservesTokenToBorrow)
        // 10 * 1 == X * 5 -> X = 2
        // 10 * 1 / 5 == X 
        
        // tokenAsCollateral/tokenToBorrow
        
        ratio = (collateralAmount*reservesTokenToBorrow)/reservesTokenAsCollateral;
        
        
        // return amount tokenToBorrow given tokenAsCollateral
        return ratio;
    }
    */
    
    /*
    // chainlink: solution to flash loan attack (static)
    function getPriceFromChainlinkOracle(IERC20 tokenToBorrow, IERC20 tokenAsCollateral, uint collateralAmount) private returns (uint) {
        // TODO implement Chainlink 
        return 5000000000000000000;
    }*/
}