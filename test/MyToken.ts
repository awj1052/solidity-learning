import hre from "hardhat";
import { expect } from "chai";
import { MyToken } from "../typechain-types";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

const mintingAmount = 100n; // bigint
const decimals = 18n;

describe("My Token", () => {
    let myTokenC: MyToken;
    let signers: HardhatEthersSigner[];

    before(async () => {
        signers = await hre.ethers.getSigners();
        myTokenC = await hre.ethers.deployContract("MyToken", ["MyToken", "MT", decimals, mintingAmount]);
    });
    describe("Basic state value check", () => {
        it("should have the correct name", async () => {
            expect(await myTokenC.name()).equal("MyToken");
        });
    
        it("should have the correct symbol", async () => {
            expect(await myTokenC.symbol()).equal("MT");
        });
    
        it("should have the correct decimals", async () => {
            expect(await myTokenC.decimals()).equal(decimals);
        });
    
        it("should return 100 totalSupply", async () => {
            expect(await myTokenC.totalSupply()).equal(mintingAmount * 10n** decimals);
        });
    })

    describe("Mint", () => {
        // 1MT = 1e18
        it("should return 1MT balance for signer 0", async () => {
            const signer0 = signers[0];
            expect(await myTokenC.balanceOf(signer0)).equal(mintingAmount * 10n ** decimals);
        });
    });

    describe("Transfer", () => {
        it("should have 0.5MT", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            // const tx = await myTokenC.transfer(hre.ethers.parseUnits("0.5", decimals), signer1.address);
            // const receipt = await tx.wait(); // 거래 끝나면 영수증
            // console.log(receipt?.logs) // 영수증이 null일수도 있음
            await expect(myTokenC.transfer(
                hre.ethers.parseUnits("0.5", decimals),
                 signer1.address
            )).to.emit(myTokenC, "Transfer")
            .withArgs(signer0.address, signer1.address, hre.ethers.parseUnits("0.5", decimals));

            expect(await myTokenC.balanceOf(signer1)).equal(hre.ethers.parseUnits("0.5", decimals));

            // typechain-types에 Event가 기록되어 있어서 쉽게 검색할 수 있음
            // const filter = myTokenC.filters.Transfer(signer0.address);
            // 이벤트, start_block, end_block
            // const logs = await myTokenC.queryFilter(filter, 0, "latest"); // query 결과가 무거움
            // console.log(logs.length);
        });

        it("should be reverted with insufficient balance error", async () => {
            const signer1 = signers[1];
            await expect( // testing framework가 대신 실행(await)하고 오류를 확인
                myTokenC.transfer(hre.ethers.parseUnits((mintingAmount + 1n).toString(), decimals), signer1.address) // 이 자체를 넘겨줌
            ).to.be.revertedWith("insufficient balance")
        });
    });

    describe("TransferFrom", () => {
        it("should emit Approval event", async () => {
            const signer1 = signers[1];
            await expect(myTokenC.approve(signer1, hre.ethers.parseUnits("10", decimals)))
            .to.emit(myTokenC, "Approval").withArgs(signer1.address, hre.ethers.parseUnits("10", decimals))
        });
        it("should be reverted with insufficient allowance error", async () => {
            const signer0 = signers[0];
            const signer1 = signers[1];
            await expect(myTokenC.connect(signer1).transferFrom(signer0.address, signer1.address, hre.ethers.parseUnits("1", decimals)))
            .to.be.revertedWith("insufficient allowance");
        });
    });
});
