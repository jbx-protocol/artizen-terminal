// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/Test.sol";

import {JBArtizenRecoveryTerminal} from "src/JBArtizenRecoveryTerminal.sol";
import {IJBArtizenRecoveryTerminal} from "src/IJBArtizenRecoveryTerminal.sol";

import {IJBProjects} from "@juicebox/interfaces/IJBProjects.sol";
import {IJBDirectory} from "@juicebox/interfaces/IJBDirectory.sol";
import {IJBSingleTokenPaymentTerminalStore3_1_1} from "@juicebox/interfaces/IJBSingleTokenPaymentTerminalStore3_1_1.sol";
import {JBPayoutRedemptionPaymentTerminal3_1_2} from "@juicebox/abstract/JBPayoutRedemptionPaymentTerminal3_1_2.sol";
import {JBFees} from "@juicebox/libraries/JBFees.sol";
import {JBTokens} from "@juicebox/libraries/JBTokens.sol";

contract MigrationIntegrationTest is Test {
    // Artizen multisig, project, and project owner.
    address immutable multisig = 0x71717DAAFF29E17641F64392f24fa21022e1C332;
    uint256 immutable projectId = 587;
    address immutable rene = 0xfe5E90ba7cDAaDba443C0C27010eB1D51327EaFb;

    // JB multisig
    address immutable jbMultisig = address(0xAF28bcB48C40dBC86f52D459A6562F658fc94B1e);
    uint256 immutable jbProjectId = 1;

    IJBProjects projects = IJBProjects(0xD8B4359143eda5B2d763E127Ed27c77addBc47d3);
    IJBDirectory directory = IJBDirectory(0x65572FB928b46f9aDB7cfe5A4c41226F636161ea);
    JBPayoutRedemptionPaymentTerminal3_1_2 ethTerminal =
        JBPayoutRedemptionPaymentTerminal3_1_2(0x1d9619E10086FdC1065B114298384aAe3F680CC0);

    function test_migrateThenDistribute() public {
        vm.createSelectFork("https://rpc.ankr.com/eth", 19192873);
        // Fund Rene's wallet.
        vm.deal(rene, 100 ether);

        // Assert that the ETH terminal is Artizen's primary terminal.
        assertEq(address(ethTerminal), address(directory.primaryTerminalOf(projectId, JBTokens.ETH)));

        // Retrieve the balance of the Artizen multisig address
        uint256 multisigBalanceBefore = address(multisig).balance;

        // Retrieve Artizen's balance from the terminal's store.
        IJBSingleTokenPaymentTerminalStore3_1_1 ethTerminalStore =
            IJBSingleTokenPaymentTerminalStore3_1_1(ethTerminal.store());
        uint256 ethTerminalBalance = ethTerminalStore.balanceOf(ethTerminal, projectId);

        // Deploy the recovery terminal.
        IJBArtizenRecoveryTerminal artizenTerminal = new JBArtizenRecoveryTerminal(projects, directory);

        // Migrate to the recovery terminal.
        vm.prank(rene);
        ethTerminal.migrate(projectId, artizenTerminal);

        // Ensure the funds have been moved out.
        assertEq(ethTerminalStore.balanceOf(ethTerminal, projectId), 0);

        // Distribute the payouts.
        vm.prank(jbMultisig);
        artizenTerminal.distributePayoutsOf(projectId, 0, 0, address(0), 0, new bytes(0));

        // Calculate the amount of fees to be taken out.
        uint256 feeAmount = JBFees.feeIn(ethTerminalBalance, artizenTerminal.fee(), 0);

        // Ensure the funds have been distributed to the Artizen multisig.
        uint256 multisigBalanceAfter = address(multisig).balance;
        assertEq(multisigBalanceAfter, multisigBalanceBefore + ethTerminalBalance - feeAmount);
    }
}
