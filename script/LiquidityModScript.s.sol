// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {Constants} from "@pancakeswap/v4-core/test/pool-cl/helpers/Constants.sol";
import {Currency} from "@pancakeswap/v4-core/src/types/Currency.sol";
import {PoolKey} from "@pancakeswap/v4-core/src/types/PoolKey.sol";
import {CLPoolParametersHelper} from "@pancakeswap/v4-core/src/pool-cl/libraries/CLPoolParametersHelper.sol";
import {PoolId, PoolIdLibrary} from "@pancakeswap/v4-core/src/types/PoolId.sol";
import {MintPointsHook} from "../src/pool-cl/MintPointsHook.sol";
import {PoolKey} from "../lib/pancake-v4-core/src/types/PoolKey.sol";
import {IHooks} from "../lib/pancake-v4-core/src/interfaces/IHooks.sol";
// import {IVault} from "../src/interfaces/IVault.sol";
import {ICLPoolManager} from "../lib/pancake-v4-core/src/pool-cl/interfaces/ICLPoolManager.sol";

/**
 * forge script script/02_DeployCLPoolManager.s.sol:DeployCLPoolManagerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 */
contract LiquidityModScript is BaseScript {
    // using PoolIdLibrary for PoolKey;
    using CLPoolParametersHelper for bytes32;

    // At the global level of your contract or library where it makes sense
    event PoolInitialized(PoolId poolId);

    address constant poolManagerAddress = address(0x76B97C7Af48A715b3CE9Fc3F11e43903F90040d7);
    address constant stablepointAddress = address(0x6cFF4a33FB158196DC39b030C2fBaeaB00731fC3);
    address constant currency0Address = address(0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238);
    address constant currency1Address = address(0xCE252C063B7C66417934C85c177AE61Bf0e9858a);
    address constant mintPointsHook = address(0x58472AD868B678749d801404930DBF8f85442F5B);

    function run() public {

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        IHooks hook = IHooks(mintPointsHook);
        ICLPoolManager poolManager = ICLPoolManager(poolManagerAddress);
        
        // Use Currency.wrap to convert address to Currency
        Currency currency0 = Currency.wrap(currency0Address);
        Currency currency1 = Currency.wrap(currency1Address);

        // create the pool key
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            hooks: hook,
            poolManager: poolManager,
            fee: uint24(0),
            // tickSpacing: 10
            parameters: bytes32(uint256(hook.getHooksRegistrationBitmap())).setTickSpacing(10)
        });

        // create the mod params
        ICLPoolManager.ModifyLiquidityParams memory params = ICLPoolManager.ModifyLiquidityParams({
            tickLower: 0,
            tickUpper: 10,
            liquidityDelta: 10
        });

        poolManager.modifyLiquidity(key, params, new bytes(0));

        vm.stopBroadcast();
    }
}
