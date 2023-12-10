// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlgorithmicTrading {
    uint256[] public prices;  // Historical prices of an asset
    uint256 public smaPeriod = 5;  // SMA period

    event TradeExecuted(address indexed trader, bool buy, uint256 amount);

    function updatePrice(uint256 newPrice) external {
        prices.push(newPrice);
    }

    function executeTradeStrategy() external {
        require(prices.length >= smaPeriod, "Not enough data for SMA");
        
        uint256 sma = calculateSMA();
        uint256 currentPrice = prices[prices.length - 1];

        if (currentPrice > sma) {
            // Buy signal
            emit TradeExecuted(msg.sender, true, currentPrice);
        } else if (currentPrice < sma) {
            // Sell signal
            emit TradeExecuted(msg.sender, false, currentPrice);
        }
    }

    function calculateSMA() public view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = prices.length - smaPeriod; i < prices.length; i++) {
            sum += prices[i];
        }
        return sum / smaPeriod;
    }
}