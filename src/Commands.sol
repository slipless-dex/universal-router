// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/**
 * @title Commands
 * @notice The opcode space for UniversalRouter. Each command is one byte
 *         in the calldata; parameters are abi-encoded and concatenated.
 *
 *         Categories:
 *           0x0X — DEX swap commands
 *           0x1X — wrap / unwrap helpers
 *           0x2X — fee / payment commands
 *           0x3X — Permit2 helpers
 *
 *         Mirror this layout in @slipless/router-sdk's `Commands` enum.
 *         A drift between the two is a wire-protocol break.
 */
library Commands {
    /* ── 0x0X — Swaps ── */
    uint256 internal constant V2_SWAP_EXACT_IN = 0x00;
    uint256 internal constant V3_SWAP_EXACT_IN = 0x01;
    uint256 internal constant PERP_FILL_EXACT_IN = 0x02;

    /* ── 0x1X — Native wrapping ── */
    uint256 internal constant WRAP_NATIVE = 0x10;
    uint256 internal constant UNWRAP_NATIVE = 0x11;

    /* ── 0x2X — Fees / payments ── */
    uint256 internal constant PAY_FEE = 0x20;
    uint256 internal constant SWEEP = 0x21;

    /* ── 0x3X — Permit2 ── */
    uint256 internal constant PERMIT2_TRANSFER_FROM = 0x30;
    uint256 internal constant PERMIT2_PERMIT = 0x31;

    uint256 internal constant COMMAND_TYPE_MASK = 0x3f;
    uint256 internal constant ALLOW_REVERT_FLAG = 0x80;
}
