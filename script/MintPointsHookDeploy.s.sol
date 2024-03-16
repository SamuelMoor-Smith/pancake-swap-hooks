// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import {BaseScript} from "./BaseScript.sol";
import {MintPointsHook} from "../src/pool-cl/MintPointsHook.sol";
// import {IVault} from "../src/interfaces/IVault.sol";
import {ICLPoolManager} from "../lib/pancake-v4-core/src/pool-cl/interfaces/ICLPoolManager.sol";

/**
 * forge script script/02_DeployCLPoolManager.s.sol:DeployCLPoolManagerScript -vvv \
 *     --rpc-url $RPC_URL \
 *     --broadcast \
 *     --slow \
 *     --verify
 */
contract MintPointsHookDeploy is BaseScript {

    address constant poolManagerAddress = address(0x76B97C7Af48A715b3CE9Fc3F11e43903F90040d7);
    address constant stablepointAddress = address(0x6cFF4a33FB158196DC39b030C2fBaeaB00731fC3);

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // address vault = getAddressFromConfig("vault");
        // console.log("vault address: ", vaultAddress);

        MintPointsHook hook = new MintPointsHook(ICLPoolManager(poolManagerAddress), stablepointAddress);
        console.log("hool contract deployed at ", address(hook));

        // console.log("Registering CLPoolManager");
        // IVault(vaultAddress).registerPoolManager(address(clPoolManager));

        vm.stopBroadcast();
    }
}
