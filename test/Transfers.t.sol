// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/*
* ERC20TestWrappern wraps the token to be tested with frequent test conditions
*
* TODO
*/
/*
contract ERC20TestWrapper{
    IERC20 token;

    constructor(address token) {
        this.token = IERC20(token);
    }

    function name() public view returns (string) {
        return token.name();
    }
    function symbol() public view returns (string) {
        return token.symbol();
    }
    function decimals() public view returns (uint8) {
        return token.decimals();
    }
    function totalSupply() public view returns (uint256) {
        return token.totalSupply();
    }
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return token.balanceOf(_owner);
    }
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return token.transfer(_to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return token.transferFrom(_from, _to, _value);
    }
    function approve(address _spender, uint256 _value) public returns (bool success) {
        return token.approve(_spender, _value);
    }
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return token.allowance(_owner, _spender);
    }

}
*/


contract Transfer is Test {

    IERC20 public ierc20;
    ERC20Impl public token;
    address public sender;
    address public receiver;
    uint256 public initialSupply = 1000 ether;

    function setUp() public {
        sender = vm.addr(1); 
        receiver = vm.addr(2);
        vm.startPrank(sender);
        token = new ERC20Impl(initialSupply);  
        vm.stopPrank();
        ierc20 = IERC20(address(token));
    }

    /* 
    * Invariant testing for total supply currently assumes
    * that there is no minting or burning of tokens 
    * As these are not neccesarily part of the ERC20 interface per EIP-20
    */
    function invariant_TotalSupply() public view {
        assertEq(ierc20.totalSupply(), initialSupply, "Total supply not correct");
    }

    function test_Transfer(uint256 amount) public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.assume(amount <= senderInitBal);

        vm.startPrank(sender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(sender), address(receiver), amount);
        bool transferPossible = ierc20.transfer(receiver, amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "ERC20 violation: transfer returned false");
        assertEq(ierc20.balanceOf(receiver), amount ,"Receiver balance not correct");
        assertEq(ierc20.balanceOf(sender), senderInitBal - amount, "Sender balance not correct");
    }
    
    function test_Zero() public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.startPrank(sender);
       bool transferPossible = ierc20.transfer(receiver, 0);
        vm.stopPrank();

        assertEq(transferPossible, true, "ERC20 violation: transfer returned false");
        assertEq(ierc20.balanceOf(receiver), 0,"Receiver balance not correct");
        assertEq(ierc20.balanceOf(sender), senderInitBal, "Sender balance not correct");
    }

    function test_RevertFrom_ToNull(uint256 amount) public {
        vm.assume(amount <= ierc20.balanceOf(sender));
        vm.startPrank(sender);
        vm.expectRevert();
        ierc20.transfer(address(0), amount);
        vm.stopPrank();
        fail("Did not revert");
    }

    function test_RevertFrom_insuffBalance(uint256 amount) public {
        uint256 senderInitBal = ierc20.balanceOf(sender);
        vm.assume(amount > senderInitBal);
        vm.startPrank(sender);
        vm.expectRevert();
        ierc20.transfer(receiver, amount);
        vm.stopPrank();
        fail("Did not revert");
    }
}

contract TransferFrom is Test {

    IERC20 public ierc20;
    ERC20Impl public token;
    address public owner;
    address public spender;
    address public receiver;
    uint256 public ownerInitBal = 100 ether;
    uint256 public spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1); 
        receiver = vm.addr(2);
        owner = vm.addr(3); 

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);  
        ierc20 = IERC20(address(token));
        bool approved = ierc20.approve(spender, spenderAllowance);
        vm.stopPrank();
        vm.assertEq(approved, true, "Test setup failed: Could not approve spender");
    }

    function invariant_TotalSupply() public view {
        assertEq(ierc20.totalSupply(), ownerInitBal, "Total supply not correct");
    }

    function test_Transfer(uint256 amount) public {
        vm.assume(amount < spenderAllowance);

        vm.startPrank(spender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(owner), address(receiver), amount);
        bool transferPossible = ierc20.transferFrom(owner, receiver, amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "Transfer returned false");
        assertEq(ierc20.balanceOf(receiver), amount ,"Receiver balance not correct");
        assertEq(ierc20.balanceOf(owner), ownerInitBal - amount, "Owner balance not correct");
    }


    function test_TransferZero() public {
        vm.startPrank(spender);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(owner), address(receiver), 0);
        bool transferPossible = ierc20.transferFrom(owner, receiver, 0);
        vm.stopPrank();

        assertEq(transferPossible, true, "Transfer returned false");
        assertEq(ierc20.balanceOf(receiver), 0,"Receiver balance not correct");
        assertEq(ierc20.balanceOf(owner), ownerInitBal, "owner balance not correct");
    }

    function test_FromSelf(uint256 amount) public {
        vm.assume(amount < ownerInitBal);

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Transfer(address(owner), address(receiver), amount);
        bool transferPossible = ierc20.transferFrom(owner, receiver, amount);
        vm.stopPrank();

        assertEq(transferPossible, true, "Transfer returned false");
        assertEq(ierc20.balanceOf(receiver), amount ,"Receiver balance not correct");
        assertEq(ierc20.balanceOf(owner), ownerInitBal - amount, "Owner balance not correct");
    }

    function test_RevertFrom_insufBalance(uint256 amount) public {
        vm.assume(amount > ownerInitBal);

        vm.startPrank(spender);
        vm.expectRevert();
        bool transferPossible = ierc20.transferFrom(owner, receiver, amount);
        vm.stopPrank();

        fail("Did not revert");
    }

    function test_RevertFrom_insufAllowance(uint256 amount) public {
        vm.assume(amount > spenderAllowance);

        vm.startPrank(spender);
        vm.expectRevert();
        bool transferPossible = ierc20.transferFrom(owner, receiver, amount);
        vm.stopPrank();

        fail("Did not revert");
    }

}