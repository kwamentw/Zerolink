// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Insurance} from "../src/Insurance.sol";

contract InsuranceTest is Test {
    Insurance insure;

    function setUp() public{
        insure = new Insurance(address(this));
    }

    function testCreatePolicy() public {
        vm.startPrank(address(this));
        Insurance.Policy memory newPolicy = Insurance.Policy({
            policyHolder: address(0xabc),
            coverageLimitAmt: 9000000e18,
            premiumAmtToPay: 7500e18,
            expiration: block.timestamp + 30000,
            payCounter:0,
            payoutReceiver: address(0xbac),
            policyCreationTimestamp: block.timestamp 
        });

        uint256 policyId = insure.createPolicy(newPolicy);
        vm.stopPrank();
        address holder = insure.getPolicyHolder(policyId); 

        assertEq(holder, address(0xabc));
    }

}