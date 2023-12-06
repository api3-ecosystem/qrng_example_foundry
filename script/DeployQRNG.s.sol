// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import {Script} from "forge-std/Script.sol";
import {Qrng} from "../src/QRNG.sol";


contract DeployQRNG is Script {
    function run() external returns (Qrng) {
        vm.startBroadcast();
        Qrng qrng = new Qrng(address(0x1));
        vm.stopBroadcast();
        return (qrng);
    }
}


// Deployment line direct
// windows
// forge create --rpc-url $env:PROVIDER_URL --private-key $env:PRIVATE_KEY --etherscan-api-key $env:ETHERSCAN_API_KEY --verify  src/QRNG.sol:Qrng --constructor-args "0x2ab9f26E18B64848cd349582ca3B55c2d06f507d"

// mac
// 
// forge create --rpc-url $PROVIDER_URL --private-key $PRIVATE_KEY --etherscan-api-key $ETHERSCAN_API_KEY --verify  src/QRNG.sol:Qrng --constructor-args "0x2ab9f26E18B64848cd349582ca3B55c2d06f507d"
