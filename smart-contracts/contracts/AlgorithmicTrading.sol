// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlgorithmicTrading {
    uint256[] public prices;  // Historical prices of an asset
    uint256 public smaPeriod = 5;  // SMA period
    uint256 public constant RSI_PERIOD = 14;
    uint256 public constant RSI_OVERBOUGHT = 70;
    uint256 public constant RSI_OVERSOLD = 30;

    event TradeExecuted(address indexed trader, bool buy, uint256 amount);

    function updatePrice(uint256 newPrice) external {
        prices.push(newPrice);
    }

    function executeTradeStrategy() external {
        require(prices.length >= smaPeriod, "Not enough data for SMA");
        require(prices.length >= RSI_PERIOD, "Not enough data for RSI");
        
        uint256 sma = calculateSMA();
        uint256 rsi = calculateRSI();
        uint256 currentPrice = prices[prices.length - 1];

        if (currentPrice > sma && rsi < RSI_OVERBOUGHT) {
            // Buy signal
            emit TradeExecuted(msg.sender, true, currentPrice);
        } else if (currentPrice < sma && rsi > RSI_OVERSOLD) {
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

    function calculateRSI() public view returns (uint256) {
        uint256 gain = 0;
        uint256 loss = 0;

        for (uint256 i = prices.length - RSI_PERIOD; i < prices.length - 1; i++) {
            if (prices[i] < prices[i + 1]) {
                gain += prices[i + 1] - prices[i];
            } else {
                loss += prices[i] - prices[i + 1];
            }
        }

        if (loss == 0) {
            return 100;
        }

        uint256 rs = gain / loss;
        return 100 - (100 / (1 + rs));
    }
}
