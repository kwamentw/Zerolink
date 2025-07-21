// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Insurance} from "../src/Insurance.sol";

/**
 * @title Insurance test
 * @author 4B
 * @notice This tests the main contract to see whether it works
 */
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

    function testRevertCreatePolicy() public {
        vm.startPrank(address(this));
        Insurance.Policy memory newPolicy = Insurance.Policy({
            policyHolder: address(0xabc),
            coverageLimitAmt: 9000000e18,
            premiumAmtToPay: 0,
            expiration: block.timestamp + 30000,
            payCounter:0,
            payoutReceiver: address(0xbac),
            policyCreationTimestamp: block.timestamp 
        });

        vm.expectRevert();
        insure.createPolicy(newPolicy);
        vm.stopPrank();
    }

    function testRevertHolderCreatePolicy() public {
        vm.startPrank(address(this));
        Insurance.Policy memory newPolicy = Insurance.Policy({
            policyHolder: address(0),
            coverageLimitAmt: 900000e18,
            premiumAmtToPay: 0,
            expiration: block.timestamp + 30000,
            payCounter:0,
            payoutReceiver: address(0xbac),
            policyCreationTimestamp: block.timestamp 
        });

        vm.expectRevert();
        insure.createPolicy(newPolicy);
        vm.stopPrank();
    }

    function testRevertReceiverCreatePolicy() public{
        vm.startPrank(address(this));
        Insurance.Policy memory newPolicy = Insurance.Policy({
            policyHolder: address(this),
            coverageLimitAmt: 9000000e18,
            premiumAmtToPay: 0,
            expiration:block.timestamp + 50000,
            payCounter:0,
            payoutReceiver: address(0),
            policyCreationTimestamp: block.timestamp
        });

        vm.expectRevert();
        insure.createPolicy(newPolicy);
        vm.stopPrank();
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

    function testRevertUpdatePolicy() public {
        // non existing id
        uint256 id = 99;


        Insurance.Policy memory updatedPolicy = Insurance.Policy({
            policyHolder: address(0xdac),
            coverageLimitAmt: 60000e18,
            premiumAmtToPay: 7500e18,
            expiration: block.timestamp + 40000,
            payCounter:0,
            payoutReceiver: address(0xbac),
            policyCreationTimestamp: block.timestamp 
        });

        vm.expectRevert();
        insure.updatePolicy(id, updatedPolicy);
    }

    function testTerminatePolicy() public {
        uint256 policyIdee = createPoli();

        vm.warp(block.timestamp + 80000);
        insure.terminatePolicy(policyIdee);

        address holder = insure.getPolicyHolder(policyIdee);
        assertEq(address(0), holder);
    }

    function testRevertTerminatePolicy() public {
        uint256 id = createPoli();
        //trying to terminate it before expiry
        vm.expectRevert();
        insure.terminatePolicy(id);
    }

    function testRevertAuthTerminate() public{
        uint256 id = createPoli();
        vm.warp(block.timestamp + 80000);
        // a random address trying to terminate address(this) poilcy
        vm.prank(address(0xddc));
        vm.expectRevert();
        insure.terminatePolicy(id);
        //observe that it reverts
    }

    function testDepositPayment() public {
        uint256 policyIdee = createPoli();

        insure.depositPayment{value: 7500e18}(policyIdee);
        uint256 amountDeposited = insure.getPolicyPayCounter(policyIdee);
        assertEq(amountDeposited, 7500e18);
    }

    function testRevertDeposit() public {
        uint256 policyIdee = createPoli();
        vm.expectRevert();
        // try to pay more than insurance payment
        insure.depositPayment{value: 7766e18}(policyIdee);
    }

    function testSubmitClaim() public {
        //creating policy
        uint256 policyIdee = createPoli();

        //making first payment
        insure.depositPayment{value: 7500e18}(policyIdee);
        vm.warp(25 weeks);
        // submiting claim
        uint256 claimid = insure.submitClaim(policyIdee, 500e18);
        uint256 claimAmount = insure.getClaimAmount(claimid);

        assertEq(claimAmount, 500e18);
    }

    function testRevertSubmitClaim() public {
        uint256 id = createPoli();
        //making first ppayment
        insure.depositPayment{value: 7500e18}(id);

        vm.warp(25 weeks);
        //lets claim
        vm.expectRevert();
        insure.submitClaim(id, 700000e18);
        // see it reverts
    } 

    function testPayoutClaim() public {
        //creating policy
        uint256 policyIdee = createPoli();

        //making first payment
        insure.depositPayment{value: 7500e18}(policyIdee);
        vm.warp(25 weeks);
        // submiting claim
        uint256 claimid = insure.submitClaim(policyIdee, 500e18);
        uint256 claimAmount = insure.getClaimAmount(claimid);

        //approving claim
        insure.approveAndPayoutClaim(claimid);

        uint256 claimPaid = insure.getClaimPaid(claimid);

        assertEq(claimPaid, claimAmount);
    }

    function testRevertPayoutClaim() public {
        // let's see whether we can payout an invalid policy
        // must revert
        uint256 policyId = 99;
        vm.expectRevert();
        insure.approveAndPayoutClaim(policyId);

    }

    function testDenyClaim() public {
        //creating policy
        uint256 policyIdee = createPoli();
        //making first payment
        insure.depositPayment{value: 7500e18}(policyIdee);
        vm.warp(25 weeks);
        // submiting claim
        uint256 claimid = insure.submitClaim(policyIdee, 500e18);

        insure.DenyClaim(policyIdee);

        uint256 claimPaid = insure.getClaimPaid(claimid);

        assertEq(claimPaid, 0);

    }

    function testChangeManager() public{
        address newManager = address(0xabc);
        address oldManager = insure.manager();
        insure.changeManager(newManager);

        assertNotEq(newManager, oldManager);
    }

    function testRevertChangeManager() public{
        address newManager = address(0xabc);
        vm.prank(newManager);
        vm.expectRevert();
        insure.changeManager(newManager);
    }

}