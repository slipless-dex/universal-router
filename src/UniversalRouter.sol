// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Commands} from "./Commands.sol";
import {Dispatcher} from "./Dispatcher.sol";

/**
 * @title UniversalRouter
 * @notice Single entrypoint for multi-step swaps across V2, V3, and perps.
 *
 *         Calldata is `bytes commands` (one byte per step) and `bytes[] inputs`
 *         (parameters per step). Commands run sequentially; an opcode with the
 *         high bit set is allowed to revert without bubbling.
 *
 *         The router holds tokens between steps. Final step must include a
 *         `SWEEP` (or send-to-recipient) to ensure no dust remains.
 */
contract UniversalRouter is Dispatcher, ReentrancyGuard, Ownable {
    error TransactionDeadlinePassed();
    error LengthMismatch();
    error CommandReverted(uint256 i, bytes data);

    constructor(address lop_, address weth_, address admin_)
        PerpFillModule(lop_)
        NativeModule(weth_)
        Ownable(admin_)
    {}

    /// @notice Execute a batch of commands.
    /// @param commands  packed command bytes
    /// @param inputs    one ABI-encoded blob per command
    /// @param deadline  unix seconds; reverts on `block.timestamp > deadline`
    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline)
        external
        payable
        nonReentrant
    {
        if (block.timestamp > deadline) revert TransactionDeadlinePassed();
        if (commands.length != inputs.length) revert LengthMismatch();

        for (uint256 i = 0; i < commands.length;) {
            uint256 command = uint8(commands[i]);
            bool allowRevert = (command & Commands.ALLOW_REVERT_FLAG) != 0;
            try this._dispatchExternal(command, inputs[i]) {
                /* ok */
            } catch (bytes memory data) {
                if (!allowRevert) revert CommandReverted(i, data);
            }
            unchecked { ++i; }
        }
    }

    /// @dev External wrapper so the try/catch can isolate per-command reverts.
    function _dispatchExternal(uint256 command, bytes calldata input) external {
        require(msg.sender == address(this), "UR: external only");
        _dispatch(command, input);
    }

    function _pairFor(address /*a*/, address /*b*/) internal view virtual override returns (address) {
        revert("UR: pairFor not configured");
    }

    receive() external payable {}
}
