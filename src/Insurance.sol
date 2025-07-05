// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//import layer zero interfaces

/**
 * @title Insurance Payments
 * @author 4B
 * @notice Please this is not meant for production
 */
contract Insurance{

    address manager; // manages insurance policies
    address owner; // can add and remove managers

    //errors 
    error PolicyExists();
    error PolicyNonExistent();

    //events
    event PolicyCreated(address policyHolder, uint256 expiration, uint256 _policyID);
    event PolicyUpdated(address policyHolder, uint256 _policyId);
    event POlicyTerminated(uint256 policyId, address policyHolder);
    event PaymentDeposited(address holder, uint256 _policyId);
    event PayoutProcessed();
    event ClaimSubmitted(uint256 claimId);
    event ClaimApproved();
    event ManagerChanged(address oldAddress, address newAddress);
    event ClaimApprovedNPaid(uint256 policyID, uint256 amt);
    event ClaimDenied(uint256 policyidee);

    struct Policy {
        address policyHolder; // owner of policy
        uint256 coverageLimitAmt; // the limit this insurance covers up to
        uint256 premiumAmtToPay; // amount holder pays every month
        uint256 expiration;// time policy will expire
        uint256 payCounter; // how many times holder has paid
        address payoutReceiver; // the address receiving the payout incase of any claim
        uint256 policyCreationTimestamp; // the time policy was created
    }

    uint256 policyID; // to track number of policies created 

    // one that creates the policy should be different from the user, the user should only make payments

    mapping (uint256 policyId => Policy holdersPolicy) public policies;

    // one user can hold more than one policy
    mapping(uint256 policyId => address _policyHolder) holderOfPolicyId;
    mapping (uint256 policyId => uint256 amountClaimed) policyClaims;
    mapping(uint256 policyId => uint256 amount) claimsPaid;

    constructor(address _manager){
        manager = _manager;
        owner = msg.sender;
    }

    modifier onlyManager {
        require(msg.sender == manager);
        _;
    }

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }

    //creates insurance policy
    function createPolicy(Policy memory newPolicy) external onlyManager returns(uint256){

        address policyHolder = newPolicy.policyHolder;

        require(newPolicy.expiration > block.timestamp, "expiration already passed");
        require(newPolicy.coverageLimitAmt > 0 && newPolicy.premiumAmtToPay > 0, "invalid coverage Amount & premiumAmt");
        require(newPolicy.payoutReceiver != address(0), "invalid receiver");

        policies[policyID].policyCreationTimestamp = block.timestamp;

        if(policies[policyID].policyHolder == address(0)){
            holderOfPolicyId[policyID] = newPolicy.policyHolder;
            policies[policyID] = newPolicy;
            emit PolicyCreated(policyHolder, newPolicy.expiration, policyID);
        } else {
            revert PolicyExists();
        }

        return policyID++;
    }



    // to update insurance policy
    function updatePolicy(uint256 _policyId, Policy memory updatedPolicy) external onlyManager{
        address policyHolder = updatedPolicy.policyHolder;
        require(policyHolder != address(0), "invalid new policy holder");
        require(updatedPolicy.expiration > block.timestamp && policies[_policyId].expiration > block.timestamp, "invalid updated expiration");
        require (updatedPolicy.payoutReceiver != address(0), "invalid receiver");

        if(updatedPolicy.policyHolder == address(0)){
            revert PolicyNonExistent();
        }

        policies[_policyId] = updatedPolicy;
        holderOfPolicyId[_policyId] = policyHolder;

        emit PolicyUpdated(policyHolder, _policyId);
    }



    // deletes the policy
    function terminatePolicy(uint256 _policyId) external onlyManager{
        Policy memory policyToCancel = policies[_policyId];
        require(block.timestamp >= policyToCancel.expiration, "Trying to terminate an active policy");
        require(policyToCancel.policyHolder != address(0), "invalid policy");
        
        delete policies[_policyId];
        delete holderOfPolicyId[_policyId];

        emit POlicyTerminated(_policyId, policyToCancel.policyHolder);

    }


    // logic to make insurance payments
    function depositPayment(uint256 _policyId) external payable{
        require(policies[_policyId].premiumAmtToPay == msg.value, "invalid amount to be paid");
        policies[_policyId].payCounter += msg.value;
        
        emit PaymentDeposited(policies[_policyId].policyHolder, _policyId);
    }

    // submits insurance claims
    // submits claim for payout incase of damage
    //check coverage of insurance see
    // check whether user has current license
    // user should have paid for at least 6 monts
    //emit submission
    function submitClaim(uint256 _policyId, uint256 amount) external returns(uint256 claimId){
        require(policies[_policyId].coverageLimitAmt > amount, "Insurance does not cover");
        uint256 periodInsurancePaid = block.timestamp > policies[_policyId].policyCreationTimestamp ? block.timestamp - policies[_policyId].policyCreationTimestamp : 0;
        require(periodInsurancePaid / 1 weeks >= 24, "You are not legible for a claim");

        policyClaims[_policyId] = amount;

        emit ClaimSubmitted(claimId);

    }

    function approveAndPayoutClaim(uint256 _policyId) external onlyManager{
        require(policyClaims[_policyId] != 0, "invalid claim");
        uint256 amountToPay = policyClaims[_policyId];
        address receiver = policies[_policyId].payoutReceiver;

        (bool okay, ) = receiver.call{value: amountToPay}("");
        require(okay,"not sent");

        claimsPaid[_policyId] += amountToPay;

        emit ClaimApprovedNPaid(_policyId, amountToPay);
    }  

    function DenyClaim(uint256 _policyId) external onlyManager{
        require(policyClaims[_policyId] != 0, "no claim");
        delete policyClaims[_policyId];
        emit ClaimDenied(_policyId);
    }



    function changeManager(address newManager) external onlyOwner{
        address oldManager = manager;
        require(newManager != address(0), "invalid address");
        require(newManager != oldManager, "same address");
        manager = newManager;
        emit ManagerChanged(oldManager, newManager);
    }  

    function getPolicyHolder(uint256 policyId) public view returns(address){
        return policies[policyId].policyHolder;
    }

    function getPolicyPayCounter(uint256 policyId) public view returns(uint256){
        return policies[policyId].payCounter;
    }
}


