// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VulnerableVault} from "../src/VulnerableVault.sol";

contract VulnerableVaultTest is Test {
    VulnerableVault public vuVault;

    function setUp() public {
        vuVault = new VulnerableVault();
    }

    function testDeposit() public {
        vm.prank(address(1));
        vuVault.deposit{value: 1 ether}();
        assertEq(vuVault.balances(address(1)), 1 ether);
        assertEq(vuVault.totalDeposits(), 1 ether);
    }
}
