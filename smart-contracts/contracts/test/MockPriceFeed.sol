// contracts/test/MockPriceFeed.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MockPriceFeed {
    int256 private _price;
    uint256 private _timestamp;

    constructor(int256 initialPrice) {
        _price = initialPrice;
        _timestamp = block.timestamp;
    }

    function latestRoundData()
        public
        view
        returns (
            uint80,
            int256,
            uint256,
            uint256,
            uint80
        )
    {
        return (0, _price, _timestamp, _timestamp, 0);
    }

    function updatePrice(int256 newPrice) external {
        _price = newPrice;
        _timestamp = block.timestamp;
    }
}
