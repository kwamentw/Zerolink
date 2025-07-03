// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Insurance} from "../src/Insurance.sol";

contract InsuranceTest is Test {
    Insurance insure;

    function setUp() public{
        insure = new Insurance(address(this));
    }

    function createPoli() public returns(uint256 policyId){
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

        policyId = insure.createPolicy(newPolicy);
        vm.stopPrank();
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

    function testUpdatePolicy() public {
        uint256 policyIdee = createPoli();

        Insurance.Policy memory updatedPolicy = Insurance.Policy({
            policyHolder: address(0xdac),
            coverageLimitAmt: 60000e18,
            premiumAmtToPay: 7500e18,
            expiration: block.timestamp + 40000,
            payCounter:0,
            payoutReceiver: address(0xbac),
            policyCreationTimestamp: block.timestamp 
        });

        insure.updatePolicy(policyIdee, updatedPolicy);
        address holder = insure.getPolicyHolder(policyIdee); 
        assertEq(holder, address(0xdac));
        
    }
    function testTerminatePolicy() public {}
    function testDepositPayment() public {}
    function testSubmitClaim() public {}
    function testPayoutClaim() public {}
    function testDenyClaim() public {}
    function testChangeManager() public{}

}