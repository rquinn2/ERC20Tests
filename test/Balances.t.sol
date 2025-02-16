// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BalanceOf is Test {
    IERC20 internal ierc20;
    ERC20Impl internal token;
    address internal owner;
    address internal spender;
    // TODO: These really shouldn't be hardcoded>...
    uint256 internal ownerInitBal = 100 ether;
    uint256 internal spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1);
        owner = vm.addr(2);

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);
        vm.stopPrank();

        ierc20 = IERC20(address(token));
    }

    /**
     * @dev Tests the `balanceOf` function to ensure it correctly returns the owner's initial balance.
     */
    function test_balanceOf() public {
        vm.startPrank(owner);
        uint256 balance = ierc20.balanceOf(owner);
        vm.stopPrank();

        vm.assertEq(balance, ownerInitBal, "Balance not correct");
    }
}

contract TotalSupply is Test {
    IERC20 internal ierc20;
    ERC20Impl internal token;
    address internal owner;
    address internal spender;
    uint256 internal ownerInitBal = 100 ether;
    uint256 internal spenderAllowance = 50 ether;

    function setUp() public {
        spender = vm.addr(1);
        owner = vm.addr(2);

        vm.startPrank(owner);
        token = new ERC20Impl(ownerInitBal);
        vm.stopPrank();

        ierc20 = IERC20(address(token));
    }

    /**
     * @dev Tests the `totalSupply` function. Total supply after no operations should be the initial supply.
     */
    function test_TotalSupply() public {
        vm.startPrank(owner);
        uint256 totalSupply = ierc20.totalSupply();
        vm.stopPrank();

        vm.assertEq(totalSupply, ownerInitBal, "Total supply not correct");
    }

    /**
     * @dev Tests the `totalSupply` function after a transfer. Total supply should remain constant.
     * @param amount The amount of tokens to transfer. Assumed to be less than or equal to the owner's balance.
     */
    function test_AfterTransfer(uint256 amount) public {
        vm.assume(amount <= ownerInitBal);

        vm.startPrank(owner);
        ierc20.transfer(spender, amount);
        uint256 totalSupply = ierc20.totalSupply();
        vm.stopPrank();

        vm.assertEq(totalSupply, ownerInitBal, "Total supply not correct");
    }
}
