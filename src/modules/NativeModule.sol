// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256) external;
    function transfer(address, uint256) external returns (bool);
    function balanceOf(address) external view returns (uint256);
}

abstract contract NativeModule {
    address public immutable weth;

    constructor(address weth_) {
        weth = weth_;
    }

    function _wrapNative(bytes calldata inputs) internal {
        (address recipient, uint256 amount) = abi.decode(inputs, (address, uint256));
        IWETH(weth).deposit{value: amount}();
        if (recipient != address(this)) {
            IWETH(weth).transfer(recipient, amount);
        }
    }

    function _unwrapNative(bytes calldata inputs) internal {
        (address recipient, uint256 amountMin) = abi.decode(inputs, (address, uint256));
        // Read full WETH balance held by this contract.
        uint256 bal = IWETH(weth).balanceOf(address(this));
        require(bal >= amountMin, "NativeModule: insufficient");
        IWETH(weth).withdraw(bal);
        (bool ok,) = recipient.call{value: bal}("");
        require(ok, "NativeModule: native send failed");
    }
}

