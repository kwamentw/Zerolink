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

    modifier onlyOwner(){
        require(msg.sender == owner, "error");
    }

    constructor(address _owner){
        owner = _owner;
    }

    function suggestOwner(address newOwner) external{}
    /**
     * delete current owner
     * check whether there is a pendingowner otherwise reject
     */
    function renounceOwnership() external{}

    function acceptOwner() exernal {}
    
}