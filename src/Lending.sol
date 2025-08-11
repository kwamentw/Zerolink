// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Lending
 * @author 4B
 * @notice please this is not production code
 */
contract Lending{

}

/**
 * @title Scanner test
 * @author 4b
 * @notice Meant for testing whether a scanner works well
 */
contract testScanner{
    address owner;
    address pendingOwner;

    event OwnerSuggested();
    event OwnerAccepted();

    modifier onlyOwner() {
        require(msg.sender == owner, "error");
        _;
    }

    constructor(address _owner){
        owner = _owner;
    }

    function suggestOwner(address newOwner) external onlyOwner{
        require(newOwner != address(0), "not a valid address");
        pendingOwner = newOwner;
        emit OwnerSuggested();
    }
    /**
     * delete current owner
     * check whether there is a pendingowner otherwise reject
     */
    function renounceOwnership() internal{
        delete owner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner,"not allowed");
        renounceOwnership();
        owner = pendingOwner;
        pendingOwner = address(0);

        emit OwnerAccepted();

    } // add emit old and new owners

    // try role base type too
    
}