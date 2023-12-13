// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

    event OrderPlaced(uint256 indexed orderId, address indexed trader, OrderType orderType, uint256 amount, uint256 price);
    event OrderExecuted(uint256 indexed orderId, uint256 amount, uint256 executedPrice);

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function placeMarketOrder(uint256 amount) external {
        uint256 marketPrice = getLatestPrice();
        orders.push(Order(msg.sender, amount, marketPrice, OrderType.Market, true));
        emit OrderPlaced(orders.length - 1, msg.sender, OrderType.Market, amount, marketPrice);
        executeOrder(orders.length - 1);
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
                executeOrder(i);
            }
        }
    }

    function executeOrder(uint256 orderId) internal {
        // Logic for order execution: interacting with DEX, liquidity pools, etc.
        // For simplicity, we'll just emit an event here.
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
            int price,
            ,
            ,
            
        ) = priceFeed.latestRoundData();
        return uint256(price);
    }
}
