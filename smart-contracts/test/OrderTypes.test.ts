import { expect } from "chai";
import { ethers, network } from "hardhat";
import { OrderTypes, OrderTypes__factory } from "../typechain-types";
import { Signer } from "ethers";

describe("OrderTypes Contract Tests", function () {
    let orderTypes: OrderTypes;
    let signers: Signer[];
    let owner: Signer;
    let user: Signer;

    const REVEAL_BLOCK_DELAY = 10; // Same as in the smart contract

    beforeEach(async () => {
        signers = await ethers.getSigners();
        owner = signers[0];
        user = signers[1];

        const mockPriceFeedAddress = ethers.Wallet.createRandom().address;
        const mockDexAddress = ethers.Wallet.createRandom().address;

        const OrderTypesFactory = await ethers.getContractFactory("OrderTypes") as OrderTypes__factory;
        orderTypes = (await OrderTypesFactory.deploy(mockPriceFeedAddress, mockDexAddress)) as OrderTypes;
    });

    it("should allow placing an order commit", async () => {
        const commitHash = ethers.keccak256("0x01");
        const tx = await orderTypes.placeOrderCommit(commitHash);
        const receipt = await tx.wait();

        // Retrieve the commit and check its properties
        const commit = await orderTypes.commits(0);
        expect(commit.hash).to.equal(commitHash);
        expect(commit.revealBlockNumber).to.equal(receipt!.blockNumber + REVEAL_BLOCK_DELAY);
        expect(commit.revealed).to.equal(false);
    });

    it("should allow revealing an order", async () => {
        const commitHash = ethers.keccak256("0x01");
        await orderTypes.placeOrderCommit(commitHash);

        await network.provider.send("evm_increaseTime", [REVEAL_BLOCK_DELAY * 15]);
        await network.provider.send("evm_mine");

        const orderData = {
            amount: 100,
            price: 200,
            orderType: 0, // Market order
        };
        const messageHash = ethers.solidityPackedKeccak256(
            ["address", "uint256", "uint256", "uint256"],
            [await user.getAddress(), orderData.amount, orderData.price, orderData.orderType]
        );
        const signature = await user.signMessage(ethers.getBytes(messageHash));

        await expect(orderTypes.connect(user).revealOrder(0, orderData.amount, orderData.price, orderData.orderType, signature))
            .to.emit(orderTypes, "OrderRevealed")
            .withArgs(0, 0, await user.getAddress(), orderData.orderType, orderData.amount, orderData.price);
    });

    it("should correctly check and execute market orders", async () => {
        // Place a commit for a market order
        const commitHash = ethers.keccak256("0x01");
        await orderTypes.placeOrderCommit(commitHash);
    
        // Advance time and blocks to allow for revealing the order
        await network.provider.send("evm_increaseTime", [REVEAL_BLOCK_DELAY * 15]);
        await network.provider.send("evm_mine");
    
        // Market order data
        const orderData = {
            amount: 100,
            price: 200, // Example price
            orderType: 0 // Market order
        };
    
        // Generate signature for revealing the order
        const messageHash = ethers.solidityPackedKeccak256(
            ["address", "uint256", "uint256", "uint256"],
            [await user.getAddress(), orderData.amount, orderData.price, orderData.orderType]
        );
        const signature = await user.signMessage(ethers.getBytes(messageHash));
    
        // Reveal the order
        await orderTypes.connect(user).revealOrder(0, orderData.amount, orderData.price, orderData.orderType, signature);
    
        // Mock current price to ensure the market order will be executed
        // This assumes your contract has a mechanism to fetch or set the current market price.
        // You may need to call a mock function or set a state variable to represent the current market price.
    
        // Check and execute orders
        await orderTypes.checkAndExecuteOrders();
    
        // Verify the order execution
        // This step depends on how your contract handles executed orders.
        // You might check for emitted events, changes in contract state, balances, etc.
        // For example:
        const order = await orderTypes.orders(0);
        expect(order.isActive).to.equal(false);
        // Further assertions can be made based on the expected outcome of the order execution.
    });

    // Additional tests for limit and stop-loss orders can be implemented similarly
});
