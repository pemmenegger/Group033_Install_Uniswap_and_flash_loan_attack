pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "./IERC20.sol";


//The borrower implementation
contract FlashBorrower is IERC3156FlashBorrower {
    enum Action {NORMAL, OTHER}
    IERC3156FlashLender lender;
    
    constructor (IERC3156FlashLender lender_) {
        lender = lender_;
    }

    /// @dev ERC-3156 Flash loan callback
    function onFlashLoan(address initiator, address token, uint256 amount, uint256 fee, bytes calldata data) external override returns(bytes32) {
        require(msg.sender == address(lender), "FlashBorrower: Untrusted lender");
        require(initiator == address(this), "FlashBorrower: Untrusted loan initiator");
        (Action action) = abi.decode(data, (Action));
        
        /*
        address myWallet = 0xbba24ce0a5643f129fb47C6C209ad7E6EF0ef56E;
        IERC20(token).transfer(myWallet, amount/2);
        IERC20(token).transferFrom(myWallet, address(this), amount/2);
        */
        
        // uniswap
        IUniswapV2Pair().swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external lock {
        
        // sushiswap
        
        
        
       
        
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }

    /// @dev Initiate a flash loan
    function flashBorrow(address token, uint256 amount) public {
        bytes memory data = abi.encode(Action.NORMAL);
        uint256 _allowance = IERC20(token).allowance(address(this), address(lender));
        uint256 _fee = lender.flashFee(token, amount);
        uint256 _repayment = amount + _fee;
        IERC20(token).approve(address(lender), _allowance + _repayment);
        lender.flashLoan(this, token, amount, data);
    }
}

