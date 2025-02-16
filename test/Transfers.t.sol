// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20} from "@openzeppelin/contracts/token/ERC20/EERC20.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
* ERC20Impl should be an implementation of a specific ERC20 token
* that performs all setup and accepts only an intiail token amount
* as a constructor argument
*/
contract ERC20Impl is ERC20 {
    // This implements the OpenZeppelin ERC20 refernce contract
    constructor(uint256 initialSupply) ERC20("TestToken", "TT") {
        _mint(msg.sender, initialSupply);
    }
}

contract Transfer is Test {

    IERC20 public erc20;
    ERC20Impl public token;
    address public sender;
    address public receiver;
    uint256 public initialSupply = 100 ether;

    function setUp() public {
        //TODO consider adding arguments to make it fuzzed
        sender = vm.addr(1); //TODO this makes the assumption 
        receiver = vm.addr(2);

        vm.startPrank(sender);
        token = new ERC20Impl(initialSupply);  // TODO: should have a better way of grabbing the address for a more general test
        erc20 = IERC20(address(token));
        vm.stopPrank();
    }

    function invariant_TotalSupply() public view {
        assertEq(erc20.totalSupply(), initialSupply, "Total supply not correct");
    }

    function test_InsufficientBal(uint256 amount) public {
        vm.assume(amount <= erc20.balanceOf(sender));
        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(erc20));
        emit IERC20.Transfer(address(sender), address(receiver), amount);
        erc20.transfer(receiver, amount);
        vm.stopPrank();
    }

    function test_Success(uint256 amount) public {
        uint256 senderInitBal = erc20.balanceOf(sender);
        // Restrict to the set of possible valid transfer amounts
        vm.assume(amount <= senderInitBal);

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(erc20));
        emit IERC20.Transfer(address(sender), address(receiver), amount);
        bool transferPossible = erc20.transfer(receiver, amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "ERC20 violation: transfer returned false");
        assertEq(erc20.balanceOf(receiver), amount ,"Receiver balance not correct");
        assertEq(erc20.balanceOf(sender), senderInitBal - amount, "Sender balance not correct");
    }

    function test_RevertFrom_insuffBalance(uint256 amount) public {
        uint256 senderInitBal = erc20.balanceOf(sender);
        vm.assume(amount > senderInitBal);

        vm.startPrank(sender);
        vm.expectRevert();
        erc20.transfer(receiver, amount);
        vm.stopPrank();
    }

    function test_Success_TransferZero() public {
        uint256 senderInitBal = erc20.balanceOf(sender);
        vm.startPrank(sender);
        vm.stopPrank();
        assertEq(erc20.balanceOf(receiver), 0,"Receiver balance not correct");
        assertEq(erc20.balanceOf(sender), senderInitBal, "Sender balance not correct");
    }
    function test_TransferNull(uint256 amount) public {
        vm.startPrank(sender);
        erc20.transfer(address(0), amount);
        vm.stopPrank();

        assertEq(erc20.balanceOf(sender), initialSupply-amount, "Sender balance not correct");
    }
}