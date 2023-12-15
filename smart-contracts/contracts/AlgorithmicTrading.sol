// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "abdk-libraries-solidity/ABDKMathQuad.sol"; // Advanced Math Library

contract AlgorithmicTrading is
    AutomationCompatibleInterface,
    Ownable,
    ReentrancyGuard
{
    using ABDKMathQuad for bytes16;

    uint256[] public prices;
    uint256 public constant MAX_PRICE_ENTRIES = 50; // Limit the number of prices to store
    uint256 public smaPeriod = 5;
    uint256 public constant RSI_PERIOD = 14;
    uint256 public constant RSI_OVERBOUGHT = 70;
    uint256 public constant RSI_OVERSOLD = 30;
    uint256 public lastUpdate;

    // Keeper variables
    uint256 public immutable interval;
    uint256 public lastTimeStamp;

    AggregatorV3Interface internal priceFeed;

    event TradeExecuted(address indexed trader, bool buy, uint256 amount);

    constructor(
        address _priceFeed,
        uint256 _updateInterval
    ) Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        interval = _updateInterval;
        lastTimeStamp = block.timestamp;
    }

    function checkUpkeep(
        bytes calldata
    ) external view override returns (bool upkeepNeeded, bytes memory) {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
        return (upkeepNeeded, "");
    }

    function performUpkeep(bytes calldata) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            updatePriceFromOracle();
        }
    }

    // Function to update price from Chainlink Oracle
    function updatePriceFromOracle() internal {
        (, int256 price, , uint256 timeStamp, ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price data");
        require(timeStamp > lastUpdate, "No new data");
        lastUpdate = timeStamp;

        // Update prices array in a circular manner
        if (prices.length < MAX_PRICE_ENTRIES) {
            prices.push(uint256(price));
        } else {
            prices[lastUpdate % MAX_PRICE_ENTRIES] = uint256(price);
        }
    }

    function executeTradeStrategy() external nonReentrant {
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
        require(prices.length >= smaPeriod, "Insufficient data for SMA");

        uint256 sum = 0;
        uint256 startIndex = prices.length > smaPeriod
            ? prices.length - smaPeriod
            : 0;
        for (uint256 i = startIndex; i < prices.length; i++) {
            sum += prices[i];
        }
        return sum / smaPeriod;
    }

    function calculateRSI() public view returns (uint256) {
        uint256 gain = 0;
        uint256 loss = 0;

        for (
            uint256 i = prices.length - RSI_PERIOD;
            i < prices.length - 1;
            i++
        ) {
            if (prices[i] < prices[i + 1]) {
                gain += (prices[i + 1] - prices[i]);
            } else {
                loss += (prices[i] - prices[i + 1]);
            }
        }

        if (loss == 0) {
            return 100;
        }

        bytes16 rs = ABDKMathQuad.fromUInt(gain).div(
            ABDKMathQuad.fromUInt(loss)
        );
        return
            ABDKMathQuad.toUInt(
                ABDKMathQuad.fromUInt(100).sub(
                    ABDKMathQuad.fromUInt(100).div(
                        ABDKMathQuad.fromUInt(1).add(rs)
                    )
                )
            );
    }
}
