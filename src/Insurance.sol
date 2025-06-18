// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

//import layer zero interfaces

/**
 * @title Insurance Payments
 * @author 4B
 * @notice Please this is not meant for production
 */
contract Insurance{

    address manager;
    address owner;

    //errors 
    error PolicyExists();
    error PolicyNonExistent();
    event PolicyCreated(address policyHolder, uint256 expiration, uint256 _policyID);

    //events
    event PolicyUpdated(address policyHolder, uint256 _policyId);
    event POlicyTerminated(uint256 policyId, address policyHolder);
    event PaymentDeposited(address holder, uint256 _policyId);
    event PayoutProcessed();
    event ClaimSubmutted();
    event ClaimApproved();
    event ManagerChanged(address oldAddress, address newAddress);

    struct Policy {
        address policyHolder;
        uint256 coverageLimitAmt;
        uint256 premiumAmtToPay;
        uint256 expiration;
        uint256 payCounter;
        address payoutReceiver;
    }

    uint256 policyID; // to track number of policies created 

    // one that creates the policy should be different from the user, the user should only make payments

    mapping (uint256 policyId => Policy holdersPolicy) public policies;

    // one user can hold more than one policy
    mapping(uint256 policyId => address _policyHolder) holderOfPolicyId;

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

    function createPolicy(Policy memory newPolicy) external payable onlyManager returns(uint256){

        address policyHolder = newPolicy.policyHolder;

        require(newPolicy.expiration > block.timestamp, "expiration already passed");
        require(newPolicy.coverageLimitAmt > 0 && newPolicy.premiumAmtToPay > 0, "invalid coverage Amount & premiumAmt");
        require(newPolicy.payoutReceiver != address(0), "invalid receiver");

        if(policies[policyID].policyHolder != address(0)){
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
    // processing payout
    function processPayout() external {

    }
    // submits insurance claims
    // submits claim for payout incase of damage
    //check coverage of insurance see
    // check whether user has current license
    // user should have paid for at least 6 monts
    //emit submission
    function submitClaim() external{}

    // Insurance body approves claim
    // only manager can approve claim
    // if user qualifies for claim payout
    // emit event
    // record claim details
    function approveClaim() external {}  

    function changeManager(address newManager) external onlyOwner{
        address oldManager = manager;
        require(newManager != address(0), "invalid address");
        require(newManager != oldManager, "same address");
        manager = newManager;
        emit ManagerChanged(oldManager, newManager);
    }  
}
