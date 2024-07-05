// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployFundMe is Script {
    function run() public returns (FundMe) {
        HelperConfig helperConfig = new HelperConfig();
        address pricefeed = helperConfig.activeNetwork();

        // now here we are deploying the contract , so owner is msg.sender.
        vm.startBroadcast();
        FundMe fundme = new FundMe(pricefeed);
        vm.stopBroadcast();
        return fundme;
    }
}
