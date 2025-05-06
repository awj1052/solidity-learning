import hre from "hardhat";
import { expect } from "chai";
import { MyToken } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { DECIMALS, MINTING_AMOUNT } from "./constant";

describe("My Token", () => {
    let myTokenC: MyToken;
    let signers: HardhatEthersSigner[];

    beforeEach(async () => {
        signers = await hre.ethers.getSigners();
        myTokenC = await hre.ethers.deployContract("MyToken", ["MyToken", "MT", DECIMALS, MINTING_AMOUNT]);
    });
    describe("Basic state value check", () => {
        it("should have the correct name", async () => {
            expect(await myTokenC.name()).equal("MyToken");
        });
    
        it("should have the correct symbol", async () => {
            expect(await myTokenC.symbol()).equal("MT");
        });
    
        it("should have the correct decimals", async () => {
            expect(await myTokenC.decimals()).equal(DECIMALS);
        });
    
        it("should return 100 totalSupply", async () => {
            expect(await myTokenC.totalSupply()).equal(MINTING_AMOUNT * 10n** DECIMALS);
        });
    })

    describe("Mint", () => {
        // 1MT = 1e18
        it("should return 1MT balance for signer 0", async () => {
            const signer0 = signers[0];
            expect(await myTokenC.balanceOf(signer0)).equal(MINTING_AMOUNT * 10n ** DECIMALS);
        });

        // TDD
        it("should return or revert when minting infinitly", async () => {
            const hacker = signers[2];
            const mintingAgainAmount = hre.ethers.parseUnits("100", DECIMALS);
            await expect(myTokenC.connect(hacker).mint(mintingAgainAmount, hacker.address)).to.be.revertedWith("You are not authorized to manage this token");
        });
    });
    describe("Transfer", () => {
        it("should have 0.5MT", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            // const tx = await myTokenC.transfer(hre.ethers.parseUnits("0.5", DECIMALS), signer1.address);
            // const receipt = await tx.wait(); // 거래 끝나면 영수증
            // console.log(receipt?.logs) // 영수증이 null일수도 있음
            await expect(myTokenC.transfer(
                hre.ethers.parseUnits("0.5", DECIMALS),
                 signer1.address
            )).to.emit(myTokenC, "Transfer")
            .withArgs(signer0.address, signer1.address, hre.ethers.parseUnits("0.5", DECIMALS));

            expect(await myTokenC.balanceOf(signer1)).equal(hre.ethers.parseUnits("0.5", DECIMALS));

            // typechain-types에 Event가 기록되어 있어서 쉽게 검색할 수 있음
            // const filter = myTokenC.filters.Transfer(signer0.address);
            // 이벤트, start_block, end_block
            // const logs = await myTokenC.queryFilter(filter, 0, "latest"); // query 결과가 무거움
            // console.log(logs.length);
        });

        it("should be reverted with insufficient balance error", async () => {
            const signer1 = signers[1];
            await expect( // testing framework가 대신 실행(await)하고 오류를 확인
                myTokenC.transfer(hre.ethers.parseUnits((MINTING_AMOUNT + 1n).toString(), DECIMALS), signer1.address) // 이 자체를 넘겨줌
            ).to.be.revertedWith("insufficient balance")
        });
    });

    describe("TransferFrom", () => {
        it("should emit Approval event", async () => {
            const signer1 = signers[1];
            await expect(myTokenC.approve(signer1, hre.ethers.parseUnits("10", DECIMALS)))
            .to.emit(myTokenC, "Approval").withArgs(signer1.address, hre.ethers.parseUnits("10", DECIMALS))
        });
        it("should be reverted with insufficient allowance error", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            //const log = await myTokenC.connect(signer1).transferFrom(signer0.address, signer1.address, hre.ethers.parseUnits("1", DECIMALS));
            //console.log(log);
            await expect(myTokenC.connect(signer1).transferFrom(signer0.address, signer1.address, hre.ethers.parseUnits("11", DECIMALS)))
            .to.be.revertedWith("insufficient allowance");
        });
    });

    describe("Assignment (approve & transferFrom)", () => {
        it("should transfer 0.5MT from signer0 to signer1", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            await myTokenC.approve(signer1.address, hre.ethers.parseUnits("10", DECIMALS));
            await expect(myTokenC.connect(signer1).transferFrom(signer0.address, signer1.address, hre.ethers.parseUnits("0.5", DECIMALS)))
            .to.emit(myTokenC, "Transfer").withArgs(signer0.address, signer1.address, hre.ethers.parseUnits("0.5", DECIMALS));
        });
    });
});
