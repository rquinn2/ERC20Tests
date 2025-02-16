// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

// Contract to test
import {ERC20Impl} from "../src/ERC20Impl.sol";

// Interface for ERC20 interface
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Approve is Test {
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
     * @dev Tests the `approve` function of the ERC20 contract.
     * @param _amount The amount of tokens the owner is allowing the spender to use. Assumed less than the owners balance.
     */
    function test_Approval(uint256 _amount) public {
        vm.assume(_amount < ownerInitBal);

        vm.startPrank(owner);
        vm.expectEmit(true, true, false, true, address(ierc20));
        // We expect an Approval event.
        emit IERC20.Approval(address(owner), address(spender), _amount);
        bool approved = ierc20.approve(spender, _amount);
        vm.stopPrank();

        vm.assertEq(approved, true, "Approve returned false");
        vm.assertEq(ierc20.allowance(owner, spender), _amount, "Allowance not correct");
    }
}

contract Allowance is Test {
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
     * @dev Tests retrieval of allowance after approval.
     * @param _amount The amount approved for the spender. Assumed to be within the owner's initial balance.
     */
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

    /**
     * @dev Tests setting and checking for a zero allowance.
     * Checks that allowance is correctly set to 0, regardless of the address being checked against.
     * @param _checkAddress Any address. The allowance should be 0 regardless.
     */
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
