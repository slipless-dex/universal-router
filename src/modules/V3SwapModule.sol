// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface ISlipplessV3SwapCallback {
    function slipplessV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external;
}

interface ISlipplessV3Pool {
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    )
        external
        returns (int256 amount0, int256 amount1);
}

abstract contract V3SwapModule is ISlipplessV3SwapCallback {
    error V3InvalidAmountDelta();
    error V3InsufficientOutput();
    error V3NotConfigured();

    // inputs = abi.encode(address recipient, uint256 amountIn, uint256 amountOutMin,
    //                    bytes path  (token0 || fee || token1 || fee || token2 ...))
    function _v3SwapExactIn(bytes calldata inputs) internal {
        (address recipient, uint256 amountIn, uint256 amountOutMin, bytes memory path) =
            abi.decode(inputs, (address, uint256, uint256, bytes));
        recipient; amountIn; amountOutMin; path;
        revert V3NotConfigured();
    }

    function slipplessV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata)
        external
        override
    {
        if (amount0Delta <= 0 && amount1Delta <= 0) revert V3InvalidAmountDelta();
    }
}
