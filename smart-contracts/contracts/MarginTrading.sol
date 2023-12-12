// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract MarginTrading is AccessControl {
    bytes32 public constant LIQUIDATOR_ROLE = keccak256("LIQUIDATOR_ROLE");

    mapping(address => uint256) public collateral;
    mapping(address => TradingPosition) public positions;

    struct TradingPosition {
        uint256 amount;
        uint256 leverage;
        uint256 entryPrice;
        bool isOpen;
    }

    // Events
    event CollateralDeposited(address indexed user, uint256 amount);
    event CollateralWithdrawn(address indexed user, uint256 amount);
    event PositionOpened(address indexed user, uint256 amount, uint256 leverage);
    event PositionClosed(address indexed user, uint256 amount, int256 profitLoss);
    event LiquidationOccurred(address indexed user, uint256 amount, int256 profitLoss);

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function depositCollateral() external payable {
        require(msg.value > 0, "No ETH sent");
        collateral[msg.sender] += msg.value;
        emit CollateralDeposited(msg.sender, msg.value);
    }

    function withdrawCollateral(uint256 amount) external {
        require(collateral[msg.sender] >= amount, "Insufficient collateral");
        require(!positions[msg.sender].isOpen, "Close position before withdrawal");
        collateral[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit CollateralWithdrawn(msg.sender, amount);
    }

    function openPosition(uint256 leverage, uint256 entryPrice) external {
        require(collateral[msg.sender] > 0, "No collateral deposited");
        require(leverage > 1 && leverage <= 10, "Invalid leverage");

        uint256 positionSize = collateral[msg.sender] * leverage;
        positions[msg.sender] = TradingPosition(positionSize, leverage, entryPrice, true);
        emit PositionOpened(msg.sender, positionSize, leverage);
    }

    function closePosition(uint256 exitPrice) external {
        TradingPosition storage position = positions[msg.sender];
        require(position.isOpen, "No open position");

        int256 profitLoss = calculateProfitLoss(position.amount, position.leverage, position.entryPrice, exitPrice);
        position.isOpen = false;

        // Update collateral based on profit or loss
        if(profitLoss > 0) {
            collateral[msg.sender] += uint256(profitLoss);
        } else if (profitLoss < 0) {
            collateral[msg.sender] -= uint256(-profitLoss);
        }

        emit PositionClosed(msg.sender, position.amount, profitLoss);
    }

    function liquidatePosition(address user, uint256 exitPrice) external onlyRole(LIQUIDATOR_ROLE) {
        TradingPosition storage position = positions[user];
        require(position.isOpen, "No open position to liquidate");

        int256 profitLoss = calculateProfitLoss(position.amount, position.leverage, position.entryPrice, exitPrice);
        position.isOpen = false;
        collateral[user] -= uint256(-profitLoss);  // Assuming profitLoss is negative

        emit LiquidationOccurred(user, position.amount, profitLoss);
    }

    function grantLiquidatorRole(address liquidator) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(LIQUIDATOR_ROLE, liquidator);
    }

    function revokeLiquidatorRole(address liquidator) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(LIQUIDATOR_ROLE, liquidator);
    }

    function calculateProfitLoss(uint256 amount, uint256 leverage, uint256 entryPrice, uint256 exitPrice) private pure returns (int256) {
        int256 valueChange = int256(exitPrice) - int256(entryPrice);
        return int256(leverage) * valueChange * int256(amount) / int256(entryPrice);
    }
}
