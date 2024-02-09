// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {JBArtizenRecoveryTerminal} from "src/JBArtizenRecoveryTerminal.sol";
import {IJBProjects} from "@juicebox/interfaces/IJBProjects.sol";
import {IJBDirectory} from "@juicebox/interfaces/IJBDirectory.sol";

contract CounterScript is Script {
    function run() public {
        IJBProjects _projects;
        IJBDirectory _directory;

        uint256 chainId = block.chainid;

        if (chainId == 1) {
            // Ethereum mainnet
            _projects = IJBProjects(0xD8B4359143eda5B2d763E127Ed27c77addBc47d3);
            _directory = IJBDirectory(0x65572FB928b46f9aDB7cfe5A4c41226F636161ea);
        } else if (chainId == 5) {
            // Goerli testnet
            _projects = IJBProjects(0x21263a042aFE4bAE34F08Bb318056C181bD96D3b);
            _directory = IJBDirectory(0x8E05bcD2812E1449f0EC3aE24E2C395F533d9A99);            
        } else {
            revert("Invalid chain ID.");
        }
        
        vm.startBroadcast();
        _deployArtizenTerminal(_projects, _directory);
        vm.stopBroadcast();
    }
    
    function _deployArtizenTerminal(IJBProjects _projects, IJBDirectory _directory) private {
        new JBArtizenRecoveryTerminal(_projects, _directory);
    }
}
