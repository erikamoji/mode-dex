import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, BigNumber, Signer } from "ethers";

describe("MarginTrading", function () {
    let marginTrading: Contract;
    let owner: Signer;
    let user1: Signer;
    let user1Address: string;
    const depositAmount = ethers.utils.parseEther("1"); // 1 ETH

    beforeEach(async function () {
        [owner, user1] = await ethers.getSigners();
        user1Address = await user1.getAddress();

        const MarginTrading = await ethers.getContractFactory("MarginTrading", owner);
        marginTrading = await MarginTrading.deploy();
        await marginTrading.deployed();
    });

    describe("Deposit Collateral", function () {
        it("Should allow users to deposit ETH as collateral", async function () {
            await expect(marginTrading.connect(user1).depositCollateral({ value: depositAmount }))
                .to.emit(marginTrading, "CollateralDeposited")
                .withArgs(user1Address, depositAmount);

            expect(await marginTrading.collateral(user1Address)).to.equal(depositAmount);
        });
    });

    describe("Withdraw Collateral", function () {
        beforeEach(async function () {
            await marginTrading.connect(user1).depositCollateral({ value: depositAmount });
        });

        it("Should allow users to withdraw their collateral", async function () {
            await expect(marginTrading.connect(user1).withdrawCollateral(depositAmount))
                .to.emit(marginTrading, "CollateralWithdrawn")
                .withArgs(user1Address, depositAmount);

            expect(await marginTrading.collateral(user1Address)).to.equal(BigNumber.from(0));
        });

        it("Should revert if user tries to withdraw more than their balance", async function () {
            const excessAmount = ethers.utils.parseEther("2"); // 2 ETH
            await expect(marginTrading.connect(user1).withdrawCollateral(excessAmount))
                .to.be.revertedWith("Insufficient collateral");
        });
    });
});
