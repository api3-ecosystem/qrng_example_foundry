// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Script} from "forge-std/Script.sol";
import {Qrng} from "../src/QRNG.sol";


contract DeployQRNG is Script {
    function run() external returns (Qrng) {
        vm.startBroadcast();
        //deploy with a variable
       // Qrng qrng = new Qrng();
        vm.stopBroadcast();
        // return (qrng);
    }
}


// Deployment line direct
//forge create --rpc-url $env:MUMBAI_RPC_URL --private-key $env:PRIVATE_KEY --etherscan-api-key $env:POLYGON_ETHERSCAN_API_KEY --verify  contracts/PriceFeed.sol:PriceFeed 