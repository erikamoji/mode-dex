// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract AlgorithmicTrading {
    uint256[] public prices;  
    uint256 public smaPeriod = 5;
    uint256 public constant RSI_PERIOD = 14;
    uint256 public constant RSI_OVERBOUGHT = 70;
    uint256 public constant RSI_OVERSOLD = 30;

    AggregatorV3Interface internal priceFeed;

    event TradeExecuted(address indexed trader, bool buy, uint256 amount);

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // Function to update price from Chainlink Oracle
    function updatePriceFromOracle() public {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        prices.push(uint256(price));
    }

    function executeTradeStrategy() external {
        require(prices.length >= smaPeriod, "Not enough data for SMA");
        require(prices.length >= RSI_PERIOD, "Not enough data for RSI");

        uint256 sma = calculateSMA();
        uint256 rsi = calculateRSI();
        uint256 currentPrice = prices[prices.length - 1];

        if (currentPrice > sma && rsi < RSI_OVERBOUGHT) {
            emit TradeExecuted(msg.sender, true, currentPrice);
        } else if (currentPrice < sma && rsi > RSI_OVERSOLD) {
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