// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Transfer is Test {

    IERC20 internal ierc20;
    ERC20Impl internal token;
    address internal sender;
    address internal receiver;
    uint256 internal initialSupply = 1000 ether;

    function setUp() public {
        sender = vm.addr(1);
        receiver = vm.addr(2);
        vm.startPrank(sender);
        token = new ERC20Impl(initialSupply);
        vm.stopPrank();
        ierc20 = IERC20(address(token));
    }

    /** 
    *   @dev Checks the total supply remains constant.
    *   Assumes no minting/burning beyond initial supply.
    */
    function invariant_TotalSupply() public view {
        assertEq(ierc20.totalSupply(), initialSupply, "Total supply not correct");
    }

    /**
    *  @dev Tests a standard token transfer between two accounts.
    *  @param _amount The amount of tokens to transfer. 
    */
    function test_Transfer(uint256 _amount) public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.assume(_amount <= senderInitBal);

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(sender), address(receiver), _amount);
        bool transferPossible = ierc20.transfer(receiver, _amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "transfer returned false");
        assertEq(ierc20.balanceOf(receiver), _amount ,"Receiver balance incorrect");
        assertEq(ierc20.balanceOf(sender), senderInitBal - _amount, "Sender balance incorrect");
    }
    
    /**
    *  @dev Tests transferring zero tokens. Checks balances.
    */
    function test_Zero() public {
        uint256 senderInitBal = ierc20.balanceOf(sender);

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(sender), address(receiver), 0);
        bool transferPossible = ierc20.transfer(receiver, 0);
        vm.stopPrank();

        assertEq(transferPossible, true, "transfer returned false");
        assertEq(ierc20.balanceOf(receiver), 0,"Receiver balance incorrect");
        assertEq(ierc20.balanceOf(sender), senderInitBal, "Sender balance incorrect");
    }
     function test_MultipleTransfers(uint256 _amount1, uint256 _amount2) public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.assume(_amount1 <= senderInitBal);

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(sender), address(receiver), _amount1);
        bool transferPossible1 = ierc20.transfer(receiver, _amount1);
        vm.stopPrank();

        assertEq(transferPossible1, true, "Transfer 1 returned false");
        assertEq(ierc20.balanceOf(receiver), _amount1, "Receiver balance incorrect");
        assertEq(ierc20.balanceOf(sender), senderInitBal - _amount1, "Sender balance incorrect");

        // Limit the second transfer to viable amounts after the first.
        vm.assume(_amount2 <= ierc20.balanceOf(sender));

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(sender), address(receiver), _amount2);
        bool transferPossible2 = ierc20.transfer(receiver, _amount2);
        vm.stopPrank();

        assertEq(transferPossible2, true, "Transfer 2 returned false");
        assertEq(ierc20.balanceOf(receiver), _amount1 + _amount2, "Receiver balance incorrect");
        assertEq(ierc20.balanceOf(sender), senderInitBal - _amount1 - _amount2, "Sender balance incorrect");
     }

    /**
    *  @dev Tests revert when transferring to the zero address.
    *  @param _amount The amount of tokens to transfer. 
    */
    function test_RevertFrom_ToNull(uint256 _amount) public {
        vm.assume(_amount <= ierc20.balanceOf(sender));

        vm.startPrank(sender);
        vm.expectRevert();
        bool transferPossible = ierc20.transfer(address(0), _amount);
        vm.stopPrank();

        assertEq(transferPossible, false, "Transfer returned true");
    }

    /**
    *  @dev Checks for revert - insufficient balance.
    *  @param _amount The amount of tokens to transfer. 
    */
    function test_RevertFrom_insuffBalance(uint256 _amount) public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.assume(_amount > senderInitBal);

        vm.startPrank(sender);
        vm.expectRevert();
        bool transferPossible = ierc20.transfer(receiver, _amount);
        vm.stopPrank();

        assertEq(transferPossible, false, "Transfer returned true");
    }
}

contract TransferFrom is Test {

    IERC20 internal ierc20;
    ERC20Impl internal token;
    address internal owner;
    address internal spender;
    address internal receiver;
    uint256 internal ownerInitBal = 100 ether;
    uint256 internal spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1);
        receiver = vm.addr(2);
        owner = vm.addr(3);

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);
        ierc20 = IERC20(address(token));
        bool approved = ierc20.approve(spender, spenderAllowance);
        vm.stopPrank();
        vm.assertEq(approved, true, "Test setup failed: Could not approve");
    }

    // Checks that the total supply is constant
    function invariant_TotalSupply() public view {
        assertEq(ierc20.totalSupply(), ownerInitBal, "Total supply not correct");
    }

    /**
    *  @dev Tests `transferFrom`.
    *  @param _amount Amount to transfer. Within spender's allowance.
    */
    function test_Transfer(uint256 _amount) public {
        vm.assume(_amount < spenderAllowance);

        vm.startPrank(spender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(owner), address(receiver), _amount);
        bool transferPossible = ierc20.transferFrom(owner, receiver, _amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "Transfer returned false");
        assertEq(ierc20.balanceOf(receiver), _amount ,"Receiver balance incorrect");
        assertEq(ierc20.balanceOf(owner), ownerInitBal - _amount, "Owner balance incorrect");
    }


function test_MultipleTransfers(uint256 _amount1, uint256 _amount2) public {
    // Ensure _amount1 is valid
    vm.assume(_amount1 <= spenderAllowance);
    vm.assume(_amount1 <= ownerInitBal);

    vm.startPrank(spender);
    vm.expectEmit(true, true, false, true, address(ierc20));
    emit IERC20.Transfer(address(owner), address(receiver), _amount1);
    bool transferPossible1 = ierc20.transferFrom(owner, receiver, _amount1);
    vm.stopPrank();

    assertEq(transferPossible1, true, "Transfer 1 returned false");
    assertEq(ierc20.balanceOf(receiver), _amount1, "Receiver balance incorrect");
    assertEq(ierc20.balanceOf(owner), ownerInitBal - _amount1, "Owner balance incorrect");

    // Limit the second transfer to viable amounts after the first. 
    vm.assume(_amount2 <= ierc20.balanceOf(owner));
    vm.assume(_amount2 <= ierc20.allowance(owner, spender));

    vm.startPrank(spender);
    vm.expectEmit(true, true, false, true, address(ierc20));
    emit IERC20.Transfer(address(owner), address(receiver), _amount2);
    bool transferPossible2 = ierc20.transferFrom(owner, receiver, _amount2);
    vm.stopPrank();

    assertEq(transferPossible2, true, "Transfer 2 returned false");
    assertEq(ierc20.balanceOf(receiver), _amount1 + _amount2, "Receiver balance incorrect");
    assertEq(ierc20.balanceOf(owner), ownerInitBal - _amount1 - _amount2, "Owner balance incorrect");
}

    /**
    *  @dev Tests a zero-value transferFrom. Checks balances.
    */
    function test_Zero() public {
        vm.startPrank(spender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(owner), address(receiver), 0);
        bool transferPossible = ierc20.transferFrom(owner, receiver, 0);
        vm.stopPrank();

        assertEq(transferPossible, true, "Transfer returned false");
        assertEq(ierc20.balanceOf(receiver), 0,"Receiver balance incorrect");
        assertEq(ierc20.balanceOf(owner), ownerInitBal, "Owner balance incorrect");
    }


    /**
    *  @dev Checks for revert - insufficient balance.
    *  @param _amount Amount to transfer.  More than owner's balance.
    */
    function test_RevertFrom_insufBalance(uint256 _amount) public {
        vm.assume(_amount > ownerInitBal);

        vm.startPrank(spender);
        vm.expectRevert();
        bool transferPossible = ierc20.transferFrom(owner, receiver, _amount);
        vm.stopPrank();
        assertEq(transferPossible, false, "Transfer returned true");
    }

    /**
    *  @dev Checks for revert - insufficient allowance.
    *  @param _amount To transfer. Exceeds spender's allowance.
    */
    function test_RevertFrom_insufAllowance(uint256 _amount) public {
        vm.assume(_amount > spenderAllowance);

        vm.startPrank(spender);
        vm.expectRevert();
        bool transferPossible = ierc20.transferFrom(owner, receiver, _amount);
        vm.stopPrank();
        assertEq(transferPossible, false, "Transfer returned true");
    }
}