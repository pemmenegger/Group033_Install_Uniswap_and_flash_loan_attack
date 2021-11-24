// SPDX-License-Identifier: UZH
pragma solidity ^0.7.0 || ^0.8.0; 
import "./IERC3156FlashBorrower.sol";
//the import above means there is another contract, that we will discusse later in this very post

interface IERC3156FlashLender {

    function maxFlashLoan(
        address token
    ) external view returns (uint256);

    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount
    ) external returns (bool);

}
