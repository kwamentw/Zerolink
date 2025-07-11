// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

//import layer zero interfaces

/**
 * @title Insurance Payments
 * @author 4B
 * @notice Please this is not meant for production
 */
contract Insurance{

    address public manager; // manages insurance policies
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

    /**
     * creates a new policy for a policy holder
     * @param newPolicy the policy to be created
     * only manager can call this
     */
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



    /**
     * Updates a policy of a policy Holder
     * @param _policyId old policy id of policy holder
     * @param updatedPolicy new policy to be updated
     */
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



    /**
     * Terminates an existing policy
     * @param _policyId id of policy to terminate
     */
    function terminatePolicy(uint256 _policyId) external onlyManager{
        Policy memory policyToCancel = policies[_policyId];
        require(block.timestamp >= policyToCancel.expiration, "Trying to terminate an active policy");
        require(policyToCancel.policyHolder != address(0), "invalid policy");
        
        delete policies[_policyId];
        delete holderOfPolicyId[_policyId];

        emit POlicyTerminated(_policyId, policyToCancel.policyHolder);

    }


    /**
     * Makes monthly payment of insurance
     * @param _policyId policy id to make payment of
     */
    function depositPayment(uint256 _policyId) external payable{
        require(policies[_policyId].premiumAmtToPay == msg.value, "invalid amount to be paid");
        policies[_policyId].payCounter += msg.value;
        
        emit PaymentDeposited(policies[_policyId].policyHolder, _policyId);
    }

    /**
     * Helps policy Holders to make insurance claims
     * @param _policyId the key to the policy to make the claim
     * @param amount amount policy holder wants to claim
     */
    function submitClaim(uint256 _policyId, uint256 amount) external returns(uint256 claimId){
        require(policies[_policyId].coverageLimitAmt > amount, "Insurance does not cover");
        uint256 periodInsurancePaid = block.timestamp > policies[_policyId].policyCreationTimestamp ? block.timestamp - policies[_policyId].policyCreationTimestamp : 0;
        require(periodInsurancePaid / 1 weeks >= 24, "You are not legible for a claim");

        policyClaims[_policyId] = amount;

        emit ClaimSubmitted(claimId);

    }

    /**
     * Approves claim made by policy holder
     * Also pays out claims
     * @param _policyId policy id to approve
     * only manager can call this function
     */
    function approveAndPayoutClaim(uint256 _policyId) external onlyManager{
        require(policyClaims[_policyId] != 0, "invalid claim");
        uint256 amountToPay = policyClaims[_policyId];
        address receiver = policies[_policyId].payoutReceiver;

        (bool okay, ) = receiver.call{value: amountToPay}("");
        require(okay,"not sent");

        claimsPaid[_policyId] += amountToPay;

        emit ClaimApprovedNPaid(_policyId, amountToPay);
    }  

    /**
     * Rejects claim of policy holder
     * @param _policyId policy id to deny
     * only manager can call this function
     */
    function DenyClaim(uint256 _policyId) external onlyManager{
        require(policyClaims[_policyId] != 0, "no claim");
        delete policyClaims[_policyId];
        emit ClaimDenied(_policyId);
    }

    /**
     * Changes manager of the protocol
     * @param newManager address of new manager
     * only owner can chnage manager
     */
    function changeManager(address newManager) external onlyOwner{
        address oldManager = manager;
        require(newManager != address(0), "invalid address");
        require(newManager != oldManager, "same address");
        manager = newManager;
        emit ManagerChanged(oldManager, newManager);
    }  

    /**
     * get address of policy holder
     * @param policyId id of policy
     */
    function getPolicyHolder(uint256 policyId) public view returns(address){
        return policies[policyId].policyHolder;
    }

    function getPolicyPayCounter(uint256 policyId) public view returns(uint256){
        return policies[policyId].payCounter;
    }

    function getClaimAmount(uint256 policyId) public view returns(uint256){
        return policyClaims[policyId];
    }

    function getClaimPaid(uint256 policyId) public view returns(uint256){
        return claimsPaid[policyId];
    }
}


