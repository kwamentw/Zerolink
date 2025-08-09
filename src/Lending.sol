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

    constructor(address _owner){
        owner = _owner;
    }

    function suggestOwner(address newOwner) external{}
    
}