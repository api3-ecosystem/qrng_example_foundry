// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Script} from "forge-std/Script.sol";
import {Qrng} from "../src/QRNG.sol";


contract DeployQRNG is Script {
    function run() external returns (Qrng) {
        vm.startBroadcast();
        //deploy with a variable
                                    //Network Airnode Address
        Qrng qrng = new Qrng(address(0x1));
        vm.stopBroadcast();
        return (qrng);
    }
}


// Deployment line direct
//forge create --rpc-url $env:PROVIDER_URL --private-key $env:PRIVATE_KEY --etherscan-api-key $env:ETHERSCAN_API_KEY --verify  src/QRNG.sol:Qrng 