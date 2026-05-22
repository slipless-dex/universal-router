// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Mirror this layout in @slipless/router-sdk's Commands enum; drift is a wire-protocol break.
// Categories: 0x0X swaps, 0x1X wrap/unwrap, 0x2X fees, 0x3X Permit2.
library Commands {
    uint256 internal constant V2_SWAP_EXACT_IN = 0x00;
    uint256 internal constant V3_SWAP_EXACT_IN = 0x01;
    uint256 internal constant PERP_FILL_EXACT_IN = 0x02;

    uint256 internal constant WRAP_NATIVE = 0x10;
    uint256 internal constant UNWRAP_NATIVE = 0x11;

    uint256 internal constant PAY_FEE = 0x20;
    uint256 internal constant SWEEP = 0x21;

    uint256 internal constant PERMIT2_TRANSFER_FROM = 0x30;
    uint256 internal constant PERMIT2_PERMIT = 0x31;

    uint256 internal constant COMMAND_TYPE_MASK = 0x3f;
    uint256 internal constant ALLOW_REVERT_FLAG = 0x80;
}
