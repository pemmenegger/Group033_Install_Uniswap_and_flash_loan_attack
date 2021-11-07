pragma solidity ^0.8.0;

import "./IERC3156FlashLender.sol";
import "./IERC20.sol";

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

    function flashLoan(IERC3156FlashBorrower receiver, address token, uint256 amount, bytes calldata data) external override returns(bool) {
        require(supportedTokens[token], "FlashLender: Unsupported currency");
        uint256 fee = _flashFee(token, amount);
        require(IERC20(token).transfer(address(receiver), amount),"FlashLender: Transfer failed");
        require(receiver.onFlashLoan(msg.sender, token, amount, fee, data) == CALLBACK_SUCCESS,"FlashLender: Callback failed");
        require(IERC20(token).transferFrom(address(receiver), address(this), amount + fee),"FlashLender: Repay failed");
        return true;
    }

    function flashFee(address token, uint256 amount) external view override returns (uint256) {
        require(supportedTokens[token],"FlashLender: Unsupported currency");
        return _flashFee(token, amount);
    }

    function _flashFee(address token,uint256 amount) internal view returns (uint256) {
        return amount * fee / 10000;
    }

    function maxFlashLoan(address token) external view override returns (uint256) {
        return supportedTokens[token] ? IERC20(token).balanceOf(address(this)) : 0;
    }
}
