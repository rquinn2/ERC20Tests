// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/*
* ERC20Impl should be an implementation of a specific ERC20 token
* that accepts only an initial supply and performs all other
* setup (minting, etc) in the constructor. This allows for standardized 
* testing of the ERC20 interface.
*/
contract ERC20Impl is ERC20 {
    // This implements the OpenZeppelin ERC20 refernce contract
    constructor(uint256 initialSupply) ERC20("TestToken", "TT") {
        _mint(msg.sender, initialSupply);
    }
}
