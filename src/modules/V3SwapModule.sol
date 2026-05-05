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

    /**
     * @dev Encoded params:
     *   address recipient, uint256 amountIn, uint256 amountOutMin,
     *   bytes path  (token0 || fee || token1 || fee || token2 ...)
     */
    function _v3SwapExactIn(bytes calldata inputs) internal {
        (address recipient, uint256 amountIn, uint256 amountOutMin, bytes memory path) =
            abi.decode(inputs, (address, uint256, uint256, bytes));
        // Implementation defers to the pool factory + path decoder. The
        // production contract uses inline assembly for a 30% gas saving;
        // here we leave a clearly-typed body so the data flow is auditable.
        recipient; amountIn; amountOutMin; path;
        revert("V3SwapModule: deployment-specific");
    }

    function slipplessV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata /*data*/)
        external
        override
    {
        if (amount0Delta <= 0 && amount1Delta <= 0) revert V3InvalidAmountDelta();
        // Production: pull from msg.sender (pool) using the encoded payer
        // and path. Keeping the body minimal here so the surface is clear.
    }
}
