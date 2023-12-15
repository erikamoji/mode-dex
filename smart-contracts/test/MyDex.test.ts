import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("MyDex", function () {
    let myDex: Contract;
    let owner: Signer;
    let marginTradingMock: Contract;
    let algorithmicTradingMock: Contract;
    let liquidityPoolMock: Contract;

    beforeEach(async function () {
        [owner] = await ethers.getSigners();

        // Deploy mocks
        const MarginTradingMock = await ethers.getContractFactory("MarginTradingMock", owner);
        marginTradingMock = await MarginTradingMock.deploy();
        await marginTradingMock.deployed();

        const AlgorithmicTradingMock = await ethers.getContractFactory("AlgorithmicTradingMock", owner);
        algorithmicTradingMock = await AlgorithmicTradingMock.deploy();
        await algorithmicTradingMock.deployed();

        const LiquidityPoolMock = await ethers.getContractFactory("LiquidityPoolMock", owner);
        liquidityPoolMock = await LiquidityPoolMock.deploy();
        await liquidityPoolMock.deployed();

        const MyDex = await ethers.getContractFactory("MyDex", owner);
        myDex = await MyDex.deploy(marginTradingMock.address, algorithmicTradingMock.address, liquidityPoolMock.address);
        await myDex.deployed();
    });

    // Example test: Registering with SFS
    it("Should register with SFS", async function () {
        await expect(myDex.registerWithSFS("0x123"))
            .to.emit(myDex, "RegisteredWithSFS")
            .withArgs("0x123");
    });

    // Additional tests...
});
