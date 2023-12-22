// deploy.ts

import { ethers } from "hardhat";

const CHAINLINK_PRICE_FEED_ADDRESS = "0xe4b9bcD7d0AA917f19019165EB89BdbbF36d2cBe";
const SFS_CONTRACT_ADDRESS = "0xBBd707815a7F7eb6897C7686274AFabd7B579Ff6";
// Replace with the actual Liquidity Pool Contract Address at a later date
const LIQUIDITY_POOL_ADDRESS = ethers.constants.AddressZero;

async function main() {
    // Deploy MarginTrading Contract
    const MarginTrading = await ethers.getContractFactory("MarginTrading");
    const marginTrading = await MarginTrading.deploy();
    await marginTrading.deployed();
    console.log("MarginTrading deployed to:", marginTrading.address);

    // Deploy AlgorithmicTrading Contract
    const AlgorithmicTrading = await ethers.getContractFactory("AlgorithmicTrading");
    const algorithmicTrading = await AlgorithmicTrading.deploy(CHAINLINK_PRICE_FEED_ADDRESS, 300);
    await algorithmicTrading.deployed();
    console.log("AlgorithmicTrading deployed to:", algorithmicTrading.address);

    // Deploy MyDex Contract with a placeholder for OrderTypes
    const MyDex = await ethers.getContractFactory("MyDex");
    const myDex = await MyDex.deploy(marginTrading.address, algorithmicTrading.address, ethers.constants.AddressZero);
    await myDex.deployed();
    console.log("MyDex deployed to:", myDex.address);

    // Deploy OrderTypes Contract with MyDex address
    const OrderTypes = await ethers.getContractFactory("OrderTypes");
    const orderTypes = await OrderTypes.deploy(CHAINLINK_PRICE_FEED_ADDRESS, myDex.address);
    await orderTypes.deployed();
    console.log("OrderTypes deployed to:", orderTypes.address);

    // Update MyDex with the actual OrderTypes address
    await myDex.setOrderTypesAddress(orderTypes.address);
    console.log(`MyDex updated with OrderTypes address: ${orderTypes.address}`);

    // Setting up the SFS for MyDex
    await myDex.registerWithSFS(SFS_CONTRACT_ADDRESS);
    console.log(`MyDex registered with SFS at ${SFS_CONTRACT_ADDRESS}`);

    // Set the liquidity pool for MyDex
    await myDex.setLiquidityPool(LIQUIDITY_POOL_ADDRESS);
    console.log(`Liquidity Pool set for MyDex at ${LIQUIDITY_POOL_ADDRESS}`);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
