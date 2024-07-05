// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    uint constant SENT_VALUE = 0.1 ether;
    uint constant STARTING_BALANCE = 10 ether;
    address USER = makeAddr("user"); // this makeAddr() will create a new address.

    function setUp() external {
        /* previous case before refactoring...
        // It is the first function which get executed.
     //   fundme = new FundMe(); // here the test file deploying the contract , so owner is FundMeTest not us!
        */
        DeployFundMe deploy = new DeployFundMe();
        fundme = deploy.run();
        vm.deal(USER, STARTING_BALANCE); // Giving USER 10 ethers.
    }

    function testMinUSD() public view {
        assertEq(fundme.MINIMUM_USD(), 5e18);
    }

    function testOwner() public view {
        console.log("Owner : ", fundme.getOwner());
        console.log("msg.sender : ", msg.sender);
        console.log("Test contract : ", address(this));
        //  assertEq(fundme.i_owner(), address(this));  // previous case when FundMeTest deploying the contract.
        assertEq(fundme.getOwner(), msg.sender); // now we are deploying the contract not FundMeTest , so owner is msg.sender(which is DeployFundMe.s.sol address)
    }

    // for testing this we have to pass the sepolia rpc url as , we are using the address of AggregateInterface that is deployed on sepolia network.
    function testGetversion() public view {
        uint256 version = fundme.getVersion();
        assertEq(version, 4);
    }

    function testfundme() public {
        vm.expectRevert();
        fundme.fund(); // As wee are not passing value while calling fundme this will revert . (And the case is pass bcoz vm.expectRevert() checks if the next line reverts or not)
    }

    modifier funders() {
        vm.prank(USER); // After this all the TXs are done by USER's address.
        fundme.fund{value: SENT_VALUE}();
        _;
    }

    function testFundersdataStructure() public funders {
        //   vm.prank(USER); // After this all the TXs are done by USER's address.
        //   fundme.fund{value: SENT_VALUE}();
        uint amount = fundme.getAddresstoAmount(USER);
        assertEq(amount, SENT_VALUE);
    }

    function testFunderArray() public funders {
        address funder = fundme.getAddress(0);
        assertEq(funder, USER);
    }

    function testWithdrawWithSingleFunder() public funders {
        // Arrange
        uint StartingOwnerBalance = fundme.getOwner().balance;
        uint EndingFundMeContractBalance = address(fundme).balance;

        // Action
        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundme).balance, 0);
        assertEq(
            fundme.getOwner().balance,
            StartingOwnerBalance + EndingFundMeContractBalance
        );
    }

    function testWithdrawWithMultipleFunders() public {
        uint160 StartingFunders = 1; // we use uint160 as we know it is used to create a  address which is used in hoax.
        uint160 EndingFunders = 10;

        for (uint160 i = StartingFunders; i < EndingFunders; i++) {
            //  1.create address & set it
            //  2.give it some ethers
            //  3.call fund()
            hoax(address(i), STARTING_BALANCE); // It does the 1 & 2 part .
            fundme.fund{value: SENT_VALUE}();
        }
        uint StartingOwnerBalance = fundme.getOwner().balance;
        uint EndingFundMeContractBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdraw();
        vm.stopPrank();

        assertEq(address(fundme).balance, 0);
        assertEq(
            fundme.getOwner().balance,
            StartingOwnerBalance + EndingFundMeContractBalance
        );
    }

    function testWithdrawWithMultipleFundersCheaper() public {
        uint160 StartingFunders = 1; // we use uint160 as we know it is used to create a  address which is used in hoax.
        uint160 EndingFunders = 10;

        for (uint160 i = StartingFunders; i < EndingFunders; i++) {
            //  1.create address & set it
            //  2.give it some ethers
            //  3.call fund()
            hoax(address(i), STARTING_BALANCE); // It does the 1 & 2 part .
            fundme.fund{value: SENT_VALUE}();
        }
        uint StartingOwnerBalance = fundme.getOwner().balance;
        uint EndingFundMeContractBalance = address(fundme).balance;

        vm.startPrank(fundme.getOwner());
        fundme.withdrawCheaper();
        vm.stopPrank();

        assertEq(address(fundme).balance, 0);
        assertEq(
            fundme.getOwner().balance,
            StartingOwnerBalance + EndingFundMeContractBalance
        );
    }
}
// To get more information about test just add -vvv (mutliple v's at the end of command :forge test)
// chisel : it is used to run solidity code into terminal (command : chisel).
