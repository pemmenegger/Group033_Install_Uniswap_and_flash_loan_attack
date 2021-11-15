// SPDX-License-Identifier: UZH
pragma solidity ^0.8.0;

interface ICollateralLoan {

    function loan(
        address tokenToBorrow, 
        address tokenAsCollateral, 
        uint collateralAmount
    ) external;
}

