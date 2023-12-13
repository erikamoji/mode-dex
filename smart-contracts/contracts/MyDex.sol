// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MarginTrading.sol";
import "./AlgorithmicTrading.sol";
import "./OrderTypes.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

interface SFSContract {
    function register(address _recipient) external returns (uint256);
}

interface ILiquidityPool {
    function getCurrentPrice(address token) external view returns (uint256);

    function executeTrade(
        address trader,
        address token,
        uint256 amount,
        uint256 price,
        bool isBuyOrder
    ) external;
}

contract MyDex is Ownable {
    MarginTrading public marginTrading;
    AlgorithmicTrading public algorithmicTrading;
    OrderTypes public orderTypes;
    address public sfsContractAddress;
    uint256 public sfsTokenId;
    ILiquidityPool public liquidityPool;

    event RegisteredWithSFS(address indexed dex, uint256 tokenId);

    constructor(
        address _marginTradingAddress,
        address _algorithmicTradingAddress,
        address _orderTypesAddress
    ) {
        marginTrading = MarginTrading(_marginTradingAddress);
        algorithmicTrading = AlgorithmicTrading(_algorithmicTradingAddress);
        orderTypes = OrderTypes(_orderTypesAddress);
    }

    // Modified function with access control
    function registerWithSFS(address _sfsContractAddress) external onlyOwner {
        SFSContract sfsContract = SFSContract(_sfsContractAddress);
        sfsTokenId = sfsContract.register(address(this));
        sfsContractAddress = _sfsContractAddress;
        emit RegisteredWithSFS(address(this), sfsTokenId);
    }

    // Set the liquidity pool (can be done in the constructor or via a separate setter function)
    function setLiquidityPool(
        address _liquidityPoolAddress
    ) external onlyOwner {
        liquidityPool = ILiquidityPool(_liquidityPoolAddress);
    }

    function executeTrade(
        address trader,
        address token,
        uint256 amount,
        uint256 price,
        bool isBuyOrder
    ) external {
        require(token != address(0), "Invalid token address");
        require(amount > 0, "Trade amount must be greater than zero");

        ILiquidityPool _liquidityPool = liquidityPool; // Cached in memory
        require(
            _liquidityPool != ILiquidityPool(address(0)),
            "Liquidity pool not set"
        );

        uint256 marketPrice = _liquidityPool.getCurrentPrice(token);

        if (isBuyOrder) {
            require(marketPrice <= price, "Market price is too high");
        } else {
            require(marketPrice >= price, "Market price is too low");
        }

        // Execute the trade on the liquidity pool
        liquidityPool.executeTrade(
            trader,
            token,
            amount,
            marketPrice,
            isBuyOrder
        );

        emit TradeExecuted(trader, amount, marketPrice, isBuyOrder);
    }

    // Additional DEX functionalities can be added here
}
