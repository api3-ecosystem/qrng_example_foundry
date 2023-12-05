// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import {Test, console} from "forge-std/Test.sol";
import {Qrng} from "../src/QRNG.sol";
import {AirnodeRrpV0} from "@api3/airnode-protocol/contracts/rrp/AirnodeRrpV0.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract QRNGTest is Test {
    AirnodeRrpV0 airnodeRrp;
    Qrng qrng;
    uint256 fork1;

    //We need the sponsor to sign off of our request response
    using ECDSA for bytes32;

    //Global variables for our test
    //(address airnode, uint256 airnodePrivateKey) = makeAddrAndKey("airnode");
    address airnode = makeAddr("airnode");
    bytes32 endpointIdUint256 = keccak256(abi.encodePacked(("endpointIdUint256")));
    bytes32 endpointIdUint256Array = keccak256(abi.encodePacked(("endpointIdUint256Array")));
    address sponsorWallet = makeAddr("sponsorWallet");

    function setUp() public {
        fork1 = vm.createFork("https://rpc.ankr.com/eth_goerli");
        vm.selectFork(fork1);
        airnodeRrp = new AirnodeRrpV0();
        vm.startPrank(msg.sender);
        qrng = new Qrng(address(airnodeRrp));
        vm.stopPrank();
    }

    function testsetRequestParams() public {
 
        vm.startPrank(address(0x1));
        vm.expectRevert();
        qrng.setRequestParameters(airnode, endpointIdUint256, endpointIdUint256Array, sponsorWallet);
        vm.stopPrank();
        // starting Prank ALL subsequent calls will come from msg.sender
        vm.startPrank(msg.sender);
        qrng.setRequestParameters(airnode, endpointIdUint256, endpointIdUint256Array, sponsorWallet);
    }

    function testMakeRequestUint256() public {

        vm.startPrank(msg.sender);
        qrng.setRequestParameters(airnode, endpointIdUint256, endpointIdUint256Array, sponsorWallet);
        vm.stopPrank();

        uint256 blockNumberToReset = block.number;
        vm.startPrank(address(qrng), address(qrng));
        // staticCall - simulate call to but not make the call to keep the request count
        bytes32 requestId = qrng.makeRequestUint256();

        // vm.rollFork(blockNumberToReset);
        // bytes32 expectedRequestId = airnodeRrp.makeFullRequest(
        //     airnode, endpointIdUint256, address(qrng), sponsorWallet, address(qrng), qrng.fulfillUint256.selector, ""
        // );
        // console.logBytes32(expectedRequestId);
      //  assertEq(requestId, expectedRequestId);
    }

    function testfulfillUint256() public {

        // creating a local airnode to just the 
        (address airnodelocal, uint256 airnodePrivateKey) = makeAddrAndKey("airnode");
    

        vm.startPrank(msg.sender);
        qrng.setRequestParameters(airnodelocal, endpointIdUint256, endpointIdUint256Array, sponsorWallet);
        vm.stopPrank();

        vm.startPrank(address(qrng));
        bytes32 requestId = qrng.makeRequestUint256();
        vm.stopPrank();

        vm.startPrank(sponsorWallet);
        uint256 randomNumber = 3244353535;
        bytes memory data = abi.encode(randomNumber);
        bytes32 messageHash = keccak256(abi.encodePacked(requestId, data)).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(airnodePrivateKey, messageHash);
        bytes memory signature = abi.encodePacked(r, s, v);
        airnodeRrp.fulfill(requestId, airnodelocal, address(qrng), qrng.fulfillUint256.selector, data, signature);
    }
}
