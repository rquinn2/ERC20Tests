// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Approve is Test {

    IERC20 public ierc20;
    ERC20Impl public token;
    address public owner;
    address public spender;
    uint256 public ownerInitBal = 100 ether;
    uint256 public spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1); 
        owner = vm.addr(2); 

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);  
        vm.stopPrank();

        ierc20 = IERC20(address(token));
    }

    function test_Approval(uint256 _amount) public {
        vm.assume(_amount < ownerInitBal);

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Approval(address(owner), address(spender), _amount);
        bool approved = ierc20.approve(spender, _amount);
        vm.stopPrank();

        vm.assertEq(approved, true, "Approve returned false");
        vm.assertEq(ierc20.allowance(owner, spender), _amount, "Allowance not correct");
    }

}

contract Allowance is Test {

    IERC20 public ierc20;
    ERC20Impl public token;
    address public owner;
    address public spender;
    uint256 public ownerInitBal = 100 ether;
    uint256 public spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1); 
        owner = vm.addr(2); 

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);  
        vm.stopPrank();

        ierc20 = IERC20(address(token));
    }

   function test_Allownace(uint256 _amount) public {
        vm.assume(_amount < ownerInitBal);

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Approval(address(owner), address(spender), _amount);
        bool approved = ierc20.approve(spender, _amount);
        vm.stopPrank();

        vm.assertEq(approved, true, "Approve returned false");
        vm.assertEq(ierc20.allowance(owner, spender), _amount, "Allowance not correct");
    }

   function test_ZeroAllownace(address _checkAddress) public {
        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true, address(ierc20));
        emit IERC20.Approval(address(owner), address(spender), 0);
        bool approved = ierc20.approve(spender, 0);
        vm.stopPrank();

        vm.assertEq(approved, true, "Approve returned false");
        vm.assertEq(ierc20.allowance(owner, _checkAddress), 0, "Allowance not correct");
    }

}
