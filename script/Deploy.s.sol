// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {JBArtizenRecoveryTerminal} from "src/JBArtizenRecoveryTerminal.sol";

// TODO.
contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        uint256 chainId = block.chainid;
        if (chainId == 1) {
            deployArtizenTerminal();
        } else {
            revert("Invalid chain ID.");
        }
    }
    
    function deployArtizenTerminal() private {
        new JBArtizenRecoveryTerminal();
    }
}
