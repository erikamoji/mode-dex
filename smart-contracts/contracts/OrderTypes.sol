// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract OrderTypes {
    struct Order {
        address trader;
        uint256 amount;
        uint256 stopLossPrice;
        bool isActive;
    }

    Order[] public orders;
    event OrderPlaced(address indexed trader, uint256 amount, uint256 stopLossPrice);
    event OrderExecuted(uint256 indexed orderId);

    function placeOrder(uint256 amount, uint256 stopLossPrice) external {
        orders.push(Order(msg.sender, amount, stopLossPrice, true));
        emit OrderPlaced(msg.sender, amount, stopLossPrice);
    }

    function checkAndExecuteOrders() external {
        for (uint i = 0; i < orders.length; i++) {
            if (orders[i].isActive) {
                // Check if stop-loss or other conditions are met
                // If so, execute the order
                emit OrderExecuted(i);
                orders[i].isActive = false;
            }
        }
    }
}