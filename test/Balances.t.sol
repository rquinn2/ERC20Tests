// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BalanceOf is Test {

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

    function test_balanceOf() public {
        vm.startPrank(owner);
        uint256 balance = ierc20.balanceOf(owner);
        vm.stopPrank();

        vm.assertEq(balance, ownerInitBal, "Balance not correct");
    }

} 

contract TotalSupply is Test {

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


    function test_TotalSupply() public {
        vm.startPrank(owner);
        uint256 totalSupply = ierc20.totalSupply();
        vm.stopPrank();

        vm.assertEq(totalSupply, ownerInitBal, "Total supply not correct");
    }
}
