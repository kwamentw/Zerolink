// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Scanner test
 * @author 4b
 * @notice Meant for testing whether a scanner works well
 */
contract testScanner1{
    address owner;
    address pendingOwner;
    uint256 ownerCounter;

    event OwnerSuggested();
    event OwnerAccepted(address oldOwner, address newOwner);

    mapping(uint256 id => address prevOwner) public prevOwners;

    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }


    constructor(address _owner){
        require(_owner != address(0));
        owner = _owner;
    }

    /**
     * A function to initiate new owner
     * @param newOwner new owner address
     * only the owner has to be able to call this
     */
    function suggestOwner(address newOwner) external onlyOwner{
        require(pendingOwner == address(0), "invalid address");
        require(newOwner != address(0), "not a valid address");
        require(owner == msg.sender, "Owner is not authorised");
        pendingOwner = newOwner;
        emit OwnerSuggested();
    }


    /**
     * Helps old owner renounce ownership
     */
    function renounceOwnership() internal{
        require(pendingOwner != address(0), "invalid");
        delete owner;
    }

    /**
     * Function to help new owner accept ownership
     */
    function acceptOwner() external {
        require(msg.sender == pendingOwner,"not allowed");
        address oldOwner = owner;
        renounceOwnership();
        ownerCounter++;
        prevOwners[ownerCounter] = oldOwner;
        owner = pendingOwner;
        pendingOwner = address(0);

        emit OwnerAccepted(owner, oldOwner);

    }
    
    /**
     * Gets previous owners
     */
    function getPrevOwners() external onlyOwner view  returns(address[] memory previOwners) {
        for (uint256 i=0; i<ownerCounter;){
            address pOwner = prevOwners[i];
            unchecked {
                i++;
            }
            previOwners[i] = pOwner;
            
        }
    }

    function getNumOfOwners() external view returns(uint256){
        uint256 number;

        for(uint256 i=0; i<ownerCounter; i++){
            number += 1; 
        }

        return number;
    }

    function getNoOfOwners() external view returns(uint16){
        return uint16(ownerCounter);
    }

    receive() payable external {}

    function sendOut(address receiver, uint256 amount) onlyOwner external payable{
        require(receiver == address(0), "Unauthorised receiver");
        (bool check,) = receiver.call{value: amount}("");
    }
}

/**
 * I think i should try developing one of the defi concepts
 * i dont know yet
 * But it is between streaming, lending or something with swapping of tokens and earning rewards
 * what of these AI agents too
 * it has to be something used frequently
 * Probably something wey go make i undersstand liquidations
 */

