// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ISlipplessV2Pair {
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
    function getReserves() external view returns (uint112, uint112, uint32);
    function token0() external view returns (address);
    function token1() external view returns (address);
}

abstract contract V2SwapModule {
    using SafeERC20 for IERC20;

    error V2InsufficientOutput();
    error V2InvalidPath();

    // inputs = abi.encode(address recipient, uint256 amountIn, uint256 amountOutMin, address[] path)
    function _v2SwapExactIn(bytes calldata inputs) internal {
        (address recipient, uint256 amountIn, uint256 amountOutMin, address[] memory path) =
            abi.decode(inputs, (address, uint256, uint256, address[]));
        if (path.length < 2) revert V2InvalidPath();

        IERC20(path[0]).safeTransfer(_pairFor(path[0], path[1]), amountIn);

        uint256 lastAmount = amountIn;
        uint256 lastHop = path.length - 1;
        for (uint256 i = 0; i < lastHop;) {
            address pair = _pairFor(path[i], path[i + 1]);
            (uint256 reserveIn, uint256 reserveOut) = _getReserves(pair, path[i]);
            uint256 amountOut = _getAmountOut(lastAmount, reserveIn, reserveOut);
            address recv = i == lastHop - 1 ? recipient : _pairFor(path[i + 1], path[i + 2]);
            (uint256 amount0Out, uint256 amount1Out) =
                path[i] == ISlipplessV2Pair(pair).token0() ? (uint256(0), amountOut) : (amountOut, uint256(0));
            ISlipplessV2Pair(pair).swap(amount0Out, amount1Out, recv, "");
            lastAmount = amountOut;
            unchecked { ++i; }
        }
        if (lastAmount < amountOutMin) revert V2InsufficientOutput();
    }

    // 30 bps fee
    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal pure returns (uint256)
    {
        uint256 amountInWithFee = amountIn * 9970;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 10_000 + amountInWithFee;
        return numerator / denominator;
    }

    function _getReserves(address pair, address tokenIn) internal view returns (uint256, uint256) {
        (uint112 r0, uint112 r1,) = ISlipplessV2Pair(pair).getReserves();
        return tokenIn == ISlipplessV2Pair(pair).token0() ? (uint256(r0), uint256(r1)) : (uint256(r1), uint256(r0));
    }

    function _pairFor(address, address) internal view virtual returns (address);
}
