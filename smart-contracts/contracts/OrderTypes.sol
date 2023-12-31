// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

interface IDex {
    function executeTrade(
        address trader,
        uint256 amount,
        uint256 price,
        bool isBuyOrder
    ) external;
}

contract OrderTypes is Ownable {
    using ECDSA for bytes32;

    enum OrderType {
        Market,
        Limit,
        StopLoss
    }

    struct Order {
        address trader;
        uint256 amount;
        uint256 price;
        OrderType orderType;
        bool isActive;
    }

    struct Commit {
        bytes32 hash;
        uint256 revealBlockNumber;
        bool revealed;
    }

    uint256 public constant REVEAL_BLOCK_DELAY = 10; // Number of blocks to wait before revealing
    mapping(uint256 => Commit) public commits;
    mapping(uint256 => Order) public orders;
    AggregatorV3Interface public priceFeed;
    IDex public dex;
    uint256 public nextCommitId;
    uint256 public nextOrderId;

    event CommitPlaced(
        uint256 indexed commitId,
        bytes32 hash,
        uint256 revealBlockNumber
    );
    event OrderRevealed(
        uint256 indexed commitId,
        uint256 indexed orderId,
        address indexed trader,
        OrderType orderType,
        uint256 amount,
        uint256 price
    );

    constructor(address _priceFeed, address _dex) Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
        dex = IDex(_dex);
    }

    function placeOrderCommit(bytes32 hash) external {
        uint256 commitId = nextCommitId++;
        commits[commitId] = Commit({
            hash: hash,
            revealBlockNumber: block.number + REVEAL_BLOCK_DELAY,
            revealed: false
        });
        emit CommitPlaced(commitId, hash, block.number + REVEAL_BLOCK_DELAY);
    }

    function revealOrder(
        uint256 commitId,
        uint256 amount,
        uint256 price,
        OrderType orderType,
        bytes memory signature
    ) external {
        Commit storage commit = commits[commitId];
        require(
            block.number >= commit.revealBlockNumber,
            "Reveal block number not yet reached"
        );
        require(!commit.revealed, "Order already revealed");

        bytes32 hash = keccak256(
            abi.encodePacked(msg.sender, amount, price, orderType)
        );
        bytes32 ethSignedHash = MessageHashUtils.toEthSignedMessageHash(hash);

        require(
            ECDSA.recover(ethSignedHash, signature) == msg.sender,
            "Invalid signature"
        );

        require(hash == commit.hash, "Hash mismatch");
        require(amount > 0, "Invalid order amount");
        require(price > 0, "Invalid order price");
        commit.revealed = true;

        uint256 orderId = nextOrderId++;
        orders[orderId] = Order(msg.sender, amount, price, orderType, true);
        emit OrderRevealed(
            commitId,
            orderId,
            msg.sender,
            orderType,
            amount,
            price
        );
    }

    function checkAndExecuteOrders() external onlyOwner {
        uint256 currentPrice = getLatestPrice();
        for (uint i = 0; i < nextOrderId; i++) {
            Order storage order = orders[i];
            if (order.isActive && isExecutable(order, currentPrice)) {
                executeOrder(i, order.orderType == OrderType.Limit);
            }
        }
    }

    function executeOrder(uint256 orderId, bool isBuyOrder) internal {
        Order storage order = orders[orderId];
        dex.executeTrade(order.trader, order.amount, order.price, isBuyOrder);
        order.isActive = false;
    }

    function isExecutable(
        Order memory order,
        uint256 currentPrice
    ) internal pure returns (bool) {
        if (order.orderType == OrderType.Market) {
            return true;
        } else if (
            order.orderType == OrderType.Limit && (order.price >= currentPrice)
        ) {
            return true;
        } else if (
            order.orderType == OrderType.StopLoss &&
            (order.price <= currentPrice)
        ) {
            return true;
        }
        return false;
    }

    function getLatestPrice() public view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
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
