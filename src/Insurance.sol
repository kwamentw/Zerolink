// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

//import layer zero interfaces

/**
 * @title Insurance Payments
 * @author 4B
 * @notice Please this is not meant for production
 */
contract Insurance{

    error PolicyExists();
    event PolicyCreated(address polcyHolder, uint256 expiration);

    struct Policy {
        address policyHolder;
        uint256 coverageLimitAmt;
        uint256 premiumAmtToPay;
        uint256 expiration;
        uint256 payCounter;
        address payoutReceiver;
    }

    // one that creates the policy should be different from the user, the user should only make payments

    mapping (address _policyHolder => Policy holdersPolicy) public policies;

    // create insurance policy with necessary params
    function createPolicy(Policy memory newPolicy) external payable{

        address policyHolder = newPolicy.policyHolder;

        require(newPolicy.expiration > block.timestamp, "expiration already passed");
        require(newPolicy.coverageLimitAmt > 0 && newPolicy.premiumAmtToPay > 0, "invalid coverage Amount & premiumAmt");
        require(newPolicy.payoutReceiver != address(0), "invalid receiver");

        if(policyHolder != address(0)){
            policies[policyHolder] = newPolicy;
            emit PolicyCreated(policyHolder, newPolicy.expiration);
        } else {
            revert PolicyExists();
        }
    }
    // to update insurance policy
    function updatePolicy() public {}
    // deletes the policy
    function terminatePolicy() external {}
    // logic to make insurance payments
    function depositPayment() external{}
    // processing payout
    function processPayout() external {}
    // submits insurance claims
    function submitClaim() external{}
    // Insurance body approves claim
    function approveClaim() external {}    
}
