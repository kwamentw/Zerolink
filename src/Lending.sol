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
contract testScanner1{
    address owner;
    address pendingOwner;

    event OwnerSuggested();
    event OwnerAccepted(address oldOwner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "error");
        _;
    }

    constructor(address _owner){
        owner = _owner;
    }

    function suggestOwner(address newOwner) external onlyOwner{
        require(pendingOwner == address(0), "set already");
        require(newOwner != address(0), "not a valid address");
        pendingOwner = newOwner;
        emit OwnerSuggested();
    }


    function renounceOwnership() internal{
        require(pendingOwner != address(0), "invalid");
        delete owner;
    }

    function acceptOwner() external {
        require(msg.sender == pendingOwner,"not allowed");
        renounceOwnership();
        address oldOwner = owner;
        owner = pendingOwner;
        pendingOwner = address(0);

        emit OwnerAccepted(oldOwner, owner);

    }

    // try role base type too
    
}


contract TestScanner2{
    //lets try another for of ownable
    // we have to test the weird cases for this scanner
}