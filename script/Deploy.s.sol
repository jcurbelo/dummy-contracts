// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {XMDemo721} from "../src/XMDemo721.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";

contract DeployScript is Script {
    string public constant INITIAL_URI =
        "ipfs://QmV93J1Sxb3JbCBfAMzJ6kt3z9zAu77tPEzEbiQJpvAEZt";

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying XMDemo721 with deployer:", deployer);

        // Start broadcasting transactions from the deployer account
        vm.startBroadcast(deployerPrivateKey);

        // Deploy proxy using the OpenZeppelin Upgrades library
        address proxyAddress = Upgrades.deployTransparentProxy(
            "XMDemo721.sol",
            deployer, // proxy admin owner
            abi.encodeCall(XMDemo721.initialize, (INITIAL_URI))
        );

        // Get the proxy contract instance
        XMDemo721 proxy = XMDemo721(proxyAddress);

        console.log("Proxy deployed at:", address(proxy));
        console.log(
            "Implementation deployed at:",
            Upgrades.getImplementationAddress(address(proxy))
        );
        console.log(
            "Proxy Admin deployed at:",
            Upgrades.getAdminAddress(address(proxy))
        );

        vm.stopBroadcast();
    }
}
