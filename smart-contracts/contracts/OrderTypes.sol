// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IDex {
    // Define interface for interacting with the DEX for executing orders.
    function executeTrade(address trader, uint256 amount, uint256 price, bool isBuyOrder) external;
}

contract OrderTypes is Ownable {
    enum OrderType { Market, Limit, StopLoss }
    
    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        OrderType orderType;
        bool isActive;
    }

    Order[] public orders;
    AggregatorV3Interface public priceFeed;
    IDex public dex;

    event OrderPlaced(uint256 indexed orderId, address indexed trader, OrderType orderType, uint256 amount, uint256 price);
    event OrderExecuted(uint256 indexed orderId, uint256 amount, uint256 executedPrice);

    constructor(address _priceFeed, address _dex) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        dex = IDex(_dex);
    }

    function placeMarketOrder(uint256 amount) external {
        uint256 marketPrice = getLatestPrice();
        orders.push(Order(msg.sender, amount, marketPrice, OrderType.Market, true));
        uint256 orderId = orders.length - 1;
        emit OrderPlaced(orderId, msg.sender, OrderType.Market, amount, marketPrice);
        executeOrder(orderId, true); // Assume market orders are buy orders for simplicity
    }

    function placeLimitOrder(uint256 amount, uint256 limitPrice) external {
        orders.push(Order(msg.sender, amount, limitPrice, OrderType.Limit, true));
        emit OrderPlaced(orders.length - 1, msg.sender, OrderType.Limit, amount, limitPrice);
    }

    function placeStopLossOrder(uint256 amount, uint256 stopLossPrice) external {
        orders.push(Order(msg.sender, amount, stopLossPrice, OrderType.StopLoss, true));
        emit OrderPlaced(orders.length - 1, msg.sender, OrderType.StopLoss, amount, stopLossPrice);
    }

    function checkAndExecuteOrders() external onlyOwner {
        uint256 currentPrice = getLatestPrice();
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].isActive && isExecutable(orders[i], currentPrice)) {
                executeOrder(i, orders[i].orderType == OrderType.Limit);
            }
        }
    }

    function executeOrder(uint256 orderId, bool isBuyOrder) internal {
        // Interact with DEX contract to execute the trade
        dex.executeTrade(orders[orderId].trader, orders[orderId].amount, orders[orderId].price, isBuyOrder);

        emit OrderExecuted(orderId, orders[orderId].amount, orders[orderId].price);
        orders[orderId].isActive = false;
    }

    function isExecutable(Order memory order, uint256 currentPrice) internal pure returns (bool) {
        if (order.orderType == OrderType.Market) {
            return true;
        } else if (order.orderType == OrderType.Limit && (order.price >= currentPrice)) {
            return true;
        } else if (order.orderType == OrderType.StopLoss && (order.price <= currentPrice)) {
            return true;
        }
        return false;
    }

    function getLatestPrice() public view returns (uint256) {
        (
            , 
            int256 price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // Additional functions to update price feed or DEX contract if needed
    function updatePriceFeed(address _newPriceFeed) external onlyOwner {
        priceFeed = AggregatorV3Interface(_newPriceFeed);
    }

    function updateDexContract(address _newDex) external onlyOwner {
        dex = IDex(_newDex);
    }
}
