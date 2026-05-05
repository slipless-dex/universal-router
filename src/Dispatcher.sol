// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Commands} from "./Commands.sol";
import {V2SwapModule} from "./modules/V2SwapModule.sol";
import {V3SwapModule} from "./modules/V3SwapModule.sol";
import {PerpFillModule} from "./modules/PerpFillModule.sol";
import {NativeModule} from "./modules/NativeModule.sol";

/**
 * @notice Decodes a single command and dispatches it to the matching module.
 *         Each command's `inputs[i]` blob is opaque to this contract and
 *         abi-decoded by the module that owns the opcode.
 *
 *         Modules are inherited so the dispatcher has direct access to
 *         their internal helpers — `delegatecall` would shred reentrancy
 *         guards, and `staticcall` would prevent state changes.
 */
abstract contract Dispatcher is V2SwapModule, V3SwapModule, PerpFillModule, NativeModule {
    error InvalidCommand(uint256 command);
    error CommandFailed(uint256 commandIdx, bytes data);

    function _dispatch(uint256 command, bytes calldata inputs) internal {
        uint256 type_ = command & Commands.COMMAND_TYPE_MASK;

        if (type_ == Commands.V2_SWAP_EXACT_IN) {
            _v2SwapExactIn(inputs);
        } else if (type_ == Commands.V3_SWAP_EXACT_IN) {
            _v3SwapExactIn(inputs);
        } else if (type_ == Commands.PERP_FILL_EXACT_IN) {
            _perpFillExactIn(inputs);
        } else if (type_ == Commands.WRAP_NATIVE) {
            _wrapNative(inputs);
        } else if (type_ == Commands.UNWRAP_NATIVE) {
            _unwrapNative(inputs);
        } else {
            revert InvalidCommand(type_);
        }
    }
}
