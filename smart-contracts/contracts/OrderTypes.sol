// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderTypes {
    enum OrderType { Market, Limit, StopLoss }
    
    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        OrderType orderType;
        bool isActive;
    }

    Order[] public orders;
    uint256 public currentMarketPrice;

    event OrderPlaced(uint256 indexed orderId, address indexed trader, OrderType orderType, uint256 amount, uint256 price);
    event OrderExecuted(uint256 indexed orderId);

    function placeMarketOrder(uint256 amount) external {
        orders.push(Order(msg.sender, amount, currentMarketPrice, OrderType.Market, true));
        emit OrderPlaced(orders.length - 1, msg.sender, OrderType.Market, amount, currentMarketPrice);
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

    function updateMarketPrice(uint256 newPrice) external {
        // This would be updated based on an external trigger, like an oracle or other price feed mechanism
        currentMarketPrice = newPrice;
        checkAndExecuteOrders();
    }

    function checkAndExecuteOrders() internal {
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].isActive && isExecutable(orders[i])) {
                executeOrder(i);
            }
        }
    }

    function executeOrder(uint256 orderId) internal {
        // Add logic here for the execution of the order. This would typically interact with other contracts or systems.
        emit OrderExecuted(orderId);
        orders[orderId].isActive = false;
    }

    function isExecutable(Order memory order) internal view returns (bool) {
        if (order.orderType == OrderType.Market) {
            return true;
        } else if (order.orderType == OrderType.Limit && (order.price >= currentMarketPrice)) {
            return true;
        } else if (order.orderType == OrderType.StopLoss && (order.price <= currentMarketPrice)) {
            return true;
        }
        return false;
    }
}