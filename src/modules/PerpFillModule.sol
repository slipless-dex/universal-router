// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISlipplessLOP {
    struct Order {
        address trader;
        bytes32 marketId;
        uint256 price;
        uint256 size;
        uint256 triggerPrice;
        uint256 expiry;
        uint256 salt;
        bytes predicate;
    }

    struct FillParams {
        Order order;
        bytes signature;
        uint256 fillSize;
        uint256 fillPrice;
        address taker;
        bytes preInteraction;
        bytes postInteraction;
    }

    function fill(FillParams calldata p) external returns (bytes32);
}

abstract contract PerpFillModule {
    address public immutable lop;

    constructor(address lop_) {
        lop = lop_;
    }

    /**
     * @dev Encoded params:
     *   ISlipplessLOP.FillParams params
     */
    function _perpFillExactIn(bytes calldata inputs) internal {
        ISlipplessLOP.FillParams memory params = abi.decode(inputs, (ISlipplessLOP.FillParams));
        ISlipplessLOP(lop).fill(params);
    }
}
