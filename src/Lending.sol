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


    constructor(address _owner){
        owner = _owner;
    }

    /**
     * A function to initiate new owner
     * @param newOwner new owner address
     * only the owner has to be able to call this
     */
    function suggestOwner(address newOwner) external {
        require(pendingOwner == address(0), "invalid address");
        require(newOwner != address(0), "not a valid address");
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
    function getPrevOwners() external view returns(address[] memory previOwners){
        for (uint256 i=0; i<ownerCounter;){
            address pOwner = prevOwners[i];
            unchecked {
                i++;
            }
            previOwners[i] = pOwner;
            
        }
    }

    function getNoOfOwners() external view returns(uint16){
        return uint16(ownerCounter);
    }

    receive() payable external {}

    function sendOut(address receiver, uint256 amount) external payable{
        (bool check,) = receiver.call{value: amount}("");
    }

    /**
     * SOME IDEAS
     * check for bounds(for i=0; i<=length; i++) - checked
     * Casting problems - checked
     * amount validation
     * MAth problems
     */
}

