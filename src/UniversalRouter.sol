// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {Commands} from "./Commands.sol";
import {Dispatcher} from "./Dispatcher.sol";

contract UniversalRouter is Dispatcher, ReentrancyGuard, Ownable {
    error TransactionDeadlinePassed();
    error LengthMismatch();
    error CommandReverted(uint256 i, bytes data);
    error ExternalOnly();
    error PairForNotConfigured();

    constructor(address lop_, address weth_, address admin_)
        PerpFillModule(lop_)
        NativeModule(weth_)
        Ownable(admin_)
    {}

    function execute(bytes calldata commands, bytes[] calldata inputs, uint256 deadline)
        external
        payable
        nonReentrant
    {
        if (block.timestamp > deadline) revert TransactionDeadlinePassed();
        if (commands.length != inputs.length) revert LengthMismatch();

        uint256 len = commands.length;
        for (uint256 i = 0; i < len;) {
            uint256 command = uint8(commands[i]);
            bool allowRevert = (command & Commands.ALLOW_REVERT_FLAG) != 0;
            try this._dispatchExternal(command, inputs[i]) {
            } catch (bytes memory data) {
                if (!allowRevert) revert CommandReverted(i, data);
            }
            unchecked { ++i; }
        }
    }

    function _dispatchExternal(uint256 command, bytes calldata input) external {
        if (msg.sender != address(this)) revert ExternalOnly();
        _dispatch(command, input);
    }

    function _pairFor(address, address) internal view virtual override returns (address) {
        revert PairForNotConfigured();
    }

    receive() external payable {}
}
