pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "../IERC20.sol";

//The Lender implementation
contract FlashLender is IERC3156FlashLender {
    bytes32 public constant CALLBACK_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");
    mapping(address => bool) public supportedTokens;
    uint256 public fee; //  1 == 0.0001 %.

    constructor(address[] memory supportedTokens_, uint256 fee_) {
        for (uint256 i = 0; i < supportedTokens_.length; i++) {
            supportedTokens[supportedTokens_[i]] = true;
        }
        fee = fee_;
    }

    function flashLoan(IERC3156FlashBorrower receiver, address tokenToFlashLoan, uint256 amountToFlashLoan) external override returns(bool) {
        require(supportedTokens[tokenToFlashLoan], "FlashLender: Unsupported currency");
        uint256 fee_internal = _flashFee(amountToFlashLoan);
        require(IERC20(tokenToFlashLoan).transfer(address(receiver), amountToFlashLoan),"FlashLender: Transfer failed");
        require(receiver.onFlashLoan(msg.sender, tokenToFlashLoan, amountToFlashLoan, fee_internal) == CALLBACK_SUCCESS,"FlashLender: Callback failed");
        require(IERC20(tokenToFlashLoan).transferFrom(address(receiver), address(this), amountToFlashLoan + fee_internal),"FlashLender: Repay failed");
        return true;
    }

    function flashFee(address tokenToFlashLoan, uint256 amountToFlashLoan) external view override returns (uint256) {
        require(supportedTokens[tokenToFlashLoan],"FlashLender: Unsupported currency");
        return _flashFee(amountToFlashLoan);
    }

    function _flashFee(uint256 amountToFlashLoan) internal view returns (uint256) {
        return amountToFlashLoan * fee / 10000;
    }

    function maxFlashLoan(address tokenToFlashLoan) external view override returns (uint256) {
        return supportedTokens[tokenToFlashLoan] ? IERC20(tokenToFlashLoan).balanceOf(address(this)) : 0;
    }
}
