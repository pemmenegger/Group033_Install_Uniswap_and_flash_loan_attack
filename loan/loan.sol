pragma solidity =0.6.6;

import "./ierc20token.sol";

contract Loan {
  
    function loan(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) external {
        address borrower = msg.sender;
        address lender = address(this);
        // uint amountOfTokenToBorrow = this.getPriceFromChainlinkOracle(tokenToBorrow, tokenAsCollateral, collateralAmount);
        uint amountOfTokenToBorrow = 5000000000000000000;
        require(IERC20(tokenToBorrow).transfer(borrower, amountOfTokenToBorrow),"token to borrow: Transfer failed");
        require(IERC20(tokenAsCollateral).transferFrom(borrower, lender, collateralAmount),"tokenAsCollateral Transfer failed");
    }
    
    // uniswap: flash loan attack
    function getPriceFromUniswap(IERC20 tokenToBorrow, IERC20 tokenAsCollateral, uint collateralAmount) private returns (uint) {
        
        // tokenAsCollateral = DAI, collateralAmount = 10
        // tokenToBorrow = ETH, amountOfTokenToBorrow = X
        // 10 * Price DAi == X * Price of ETH
        // Dai/ETH -> 1 DAI / 5 ETH -> Dai/ETH = 5
        // 10 * 1 == X * 5 -> X = 2
        
        // tokenAsCollateral/tokenToBorrow
        
        
        // IUniswapV2Pair(pairaddress).getReserves(to); ?? 
        
        return 10000000000000000000;
    }
    
    // chainlink: solution to flash loan attack (static)
    function getPriceFromChainlinkOracle(IERC20 tokenToBorrow, IERC20 tokenAsCollateral, uint collateralAmount) private returns (uint) {
        // TODO implement Chainlink 
        return 5000000000000000000;
    }
}