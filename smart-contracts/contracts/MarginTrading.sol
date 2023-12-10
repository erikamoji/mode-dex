// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MarginTrading {
    mapping(address => uint256) public collateral;

    // Events
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event PositionTaken(address indexed user, uint256 leverage, uint256 amount);

    function depositCollateral() external payable {
        require(msg.value > 0, "No ETH sent");
        collateral[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "Insufficient collateral");
        collateral[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function takeLeveragedPosition(uint256 leverage) external {
        require(leverage > 1 && leverage <= 10, "Invalid leverage");
        uint256 amount = collateral[msg.sender] * leverage;
        collateral[msg.sender] = 0;
        // Additional logic for handling leveraged positions
        emit PositionTaken(msg.sender, leverage, amount);
    }
}