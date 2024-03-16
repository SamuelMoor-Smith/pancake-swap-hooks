// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolKey} from "@pancakeswap/v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "@pancakeswap/v4-core/src/types/BalanceDelta.sol";
import {PoolId, PoolIdLibrary} from "@pancakeswap/v4-core/src/types/PoolId.sol";
import {ICLPoolManager} from "@pancakeswap/v4-core/src/pool-cl/interfaces/ICLPoolManager.sol";
import {CLBaseHook} from "./CLBaseHook.sol";

import {IStablepoint} from "../interfaces/IStablepoint.sol";

/// @notice Based on CLCounterHook, this hook will mint lp tokens for stablecoin pools
contract MintPointsHook is CLBaseHook {
    using PoolIdLibrary for PoolKey;
    IStablepoint public stablepoint;
    uint256 public mintPoints;
    
    address public constant BURN_CONTRACT = address(0);

    // constructor(ICLPoolManager _poolManager) CLBaseHook(_poolManager) {}
    // Constructor modification to include Stablepoint address
    constructor(ICLPoolManager _poolManager, address _stablepointAddress) CLBaseHook(_poolManager) {
        stablepoint = IStablepoint(_stablepointAddress);
    }

    function getHooksRegistrationBitmap() external pure override returns (uint16) {
        return _hooksRegistrationBitmapFrom(
            Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: false,
                afterAddLiquidity: true,
                beforeRemoveLiquidity: true,
                afterRemoveLiquidity: true,
                beforeSwap: false,
                afterSwap: false,
                beforeDonate: false,
                afterDonate: false,
                noOp: false
            })
        );
    }

    /// @notice Hook function that gets called after liquidity is added
    /// @dev Mints tokens proportional to the added liquidity
    function afterAddLiquidity(
        address user,
        PoolKey calldata key,
        ICLPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta balanceDelta,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {

        mintPoints++; // For testing purposes
        uint256 amount = calculateAbsolutePointAmount(balanceDelta);
        stablepoint.mint(user, amount);

        return this.afterAddLiquidity.selector;
    }

    /// @notice Hook function that gets called before liquidity is removed
    /// @dev Checks if the user has enough tokens to remove the specified liquidity
    function beforeRemoveLiquidity(
        address user,
        PoolKey calldata key,
        ICLPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
        
        uint256 amount = safeInt256ToUint256(params.liquidityDelta);
        // uint256 amount = calculateAbsolutePointAmount(balanceDelta);
        require(stablepoint.balanceOf(user) >= amount, "Insufficient tokens to remove liquidity");

        return this.beforeRemoveLiquidity.selector;
    }

    /// @notice Hook function that gets called after liquidity is removed
    /// @dev Burns the equivalent amount of tokens by transferring them to the burn address 
    function afterRemoveLiquidity(
        address user,
        PoolKey calldata key,
        ICLPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta balanceDelta,
        bytes calldata
    ) external override poolManagerOnly returns (bytes4) {
        
        uint256 amount = calculateAbsolutePointAmount(balanceDelta);
        require(stablepoint.transferFrom(user, BURN_CONTRACT, amount), "Transfer failed: Must approve token transfer before removing liquidity");

        return this.afterRemoveLiquidity.selector;
    }

    // Simplified function to calculate the total points based on the sum of stablecoins added or removed
    function calculateAbsolutePointAmount(BalanceDelta balanceDelta) private pure returns (uint256) {
        uint256 amount0 = safeInt128ToUint256(balanceDelta.amount0());
        uint256 amount1 = safeInt128ToUint256(balanceDelta.amount1());
        return amount0 + amount1;
    }

    function safeInt128ToUint256(int128 value) private pure returns (uint256) {
        if(value < 0) {
            return uint256(-int256(value)); // Convert negative values to their absolute value then to uint256
        } else {
            return uint256(int256(value)); // Convert positive values directly
        }
    }

    function safeInt256ToUint256(int256 value) private pure returns (uint256) {
        if(value < 0) {
            return uint256(-value); // Convert negative values to their absolute value then to uint256
        } else {
            return uint256(value); // Convert positive values directly
        }
    }
}