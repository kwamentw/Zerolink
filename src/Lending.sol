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

        emit OwnerAccepted(owner, oldOwner);

    }
    
}

