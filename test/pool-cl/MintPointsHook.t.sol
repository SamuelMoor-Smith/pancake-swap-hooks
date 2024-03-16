// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {MockERC20} from "solmate/test/utils/mocks/MockERC20.sol";
import {Test} from "forge-std/Test.sol";
import {Constants} from "@pancakeswap/v4-core/test/pool-cl/helpers/Constants.sol";
import {Currency} from "@pancakeswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@pancakeswap/v4-core/src/types/PoolKey.sol";
import {CLPoolParametersHelper} from "@pancakeswap/v4-core/src/pool-cl/libraries/CLPoolParametersHelper.sol";
import {MintPointsHook} from "../../src/pool-cl/MintPointsHook.sol";
import {CLTestUtils} from "./utils/CLTestUtils.sol";
import {CLPoolParametersHelper} from "@pancakeswap/v4-core/src/pool-cl/libraries/CLPoolParametersHelper.sol";
import {PoolIdLibrary} from "@pancakeswap/v4-core/src/types/PoolId.sol";
import {ICLSwapRouterBase} from "@pancakeswap/v4-periphery/src/pool-cl/interfaces/ICLSwapRouterBase.sol";

contract MintPointsHookTest is Test, CLTestUtils {
    using PoolIdLibrary for PoolKey;
    using CLPoolParametersHelper for bytes32;

    MintPointsHook mintPointsHook;
    Currency currency0;
    Currency currency1;
    PoolKey key;

    function setUp() public {
        (currency0, currency1) = deployContractsWithTokens();
        mintPointsHook = new MintPointsHook(poolManager, address(0)); // Change to random address to satisfy test

        // create the pool key
        key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            hooks: mintPointsHook,
            poolManager: poolManager,
            fee: uint24(3000), // 0.3% fee
            // tickSpacing: 10
            parameters: bytes32(uint256(mintPointsHook.getHooksRegistrationBitmap())).setTickSpacing(10)
        });

        // initialize pool at 1:1 price point (assume stablecoin pair)
        poolManager.initialize(key, Constants.SQRT_RATIO_1_1, new bytes(0));
    }

    // function testMintPointsCallback() public {
    //     assertEq(mintPointsHook.mintPoints(), 0);

    //     MockERC20(Currency.unwrap(currency0)).mint(address(this), 1 ether);
    //     MockERC20(Currency.unwrap(currency1)).mint(address(this), 1 ether);
    //     addLiquidity(key, 1 ether, 1 ether, -60, 60);

    //     assertEq(mintPointsHook.mintPoints(), 1);
    // }

    // function testRemoveCallback() public {
    //     assertEq(mintPointsHook.mintPoints(), 0);

    //     MockERC20(Currency.unwrap(currency0)).mint(address(this), 1 ether);
    //     MockERC20(Currency.unwrap(currency1)).mint(address(this), 1 ether);
    //     removeLiquidity(key, 1 ether, 1 ether, -60, 60);

    //     assertEq(mintPointsHook.mintPoints(), 1);
    // }
}
