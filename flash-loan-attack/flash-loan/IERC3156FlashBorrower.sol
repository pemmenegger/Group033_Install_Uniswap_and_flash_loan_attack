// SPDX-License-Identifier: UZH
pragma solidity ^0.7.0 || ^0.8.0;

interface IERC3156FlashBorrower {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee
    ) external returns (bytes32);
}
