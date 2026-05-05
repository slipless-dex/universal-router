// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {Commands} from "../src/Commands.sol";

contract CommandsTest is Test {
    function test_opcodes_unique() external pure {
        // Sanity: every documented opcode is in the type-mask range and
        // they're all distinct. Catches future PRs that accidentally
        // overlap with the ALLOW_REVERT high bit.
        uint256[10] memory codes = [
            Commands.V2_SWAP_EXACT_IN,
            Commands.V3_SWAP_EXACT_IN,
            Commands.PERP_FILL_EXACT_IN,
            Commands.WRAP_NATIVE,
            Commands.UNWRAP_NATIVE,
            Commands.PAY_FEE,
            Commands.SWEEP,
            Commands.PERMIT2_TRANSFER_FROM,
            Commands.PERMIT2_PERMIT,
            uint256(0xFE) // sentinel
        ];
        for (uint256 i = 0; i < codes.length; i++) {
            for (uint256 j = i + 1; j < codes.length; j++) {
                assertTrue(codes[i] != codes[j], "duplicate opcode");
            }
            assertLt(codes[i], 0x40, "opcode in TYPE mask");
        }
    }
}
