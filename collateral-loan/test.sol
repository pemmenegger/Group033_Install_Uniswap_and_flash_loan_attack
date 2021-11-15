pragma solidity =0.6.6;

import "./ierc20token.sol";
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Pair.sol';
import '../uniswap-v2/v2-core/contracts/interfaces/IUniswapV2Factory.sol';

contract Test {
    address public token0;
    uint public reservesTokenToBorrow;
    uint public reservesTokenAsCollateral;
    uint public ratio;
    
    // uniswap: flash loan attack
    function getPriceFromUniswap(address tokenToBorrow, address tokenAsCollateral, uint collateralAmount) external returns (address) {
        address pairAddress = IUniswapV2Factory(0xeB8749f7394AfE2A5cf44251d196763C1E2aC5Cb).getPair(tokenToBorrow, tokenAsCollateral);
        IUniswapV2Pair pair = IUniswapV2Pair(pairAddress);
        (uint Res0, uint Res1,) = pair.getReserves();
        
        token0 = pair.token0();
        reservesTokenToBorrow = tokenToBorrow == token0 ? Res0 : Res1;
        reservesTokenAsCollateral = tokenToBorrow == token0 ? Res1 : Res0;
        
        ratio = (collateralAmount*reservesTokenToBorrow)/reservesTokenAsCollateral;

        return pair.token0();
    }
    
    
    /*
    // chainlink: solution to flash loan attack (static)
    function getPriceFromChainlinkOracle(IERC20 tokenToBorrow, IERC20 tokenAsCollateral, uint collateralAmount) private returns (uint) {
        // TODO implement Chainlink 
        return 5000000000000000000;
    }*/
}
