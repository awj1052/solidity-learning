import hre from "hardhat";
import { NativeBank } from "../typechain-types/NativeBank";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";
import { expect } from "chai";
import { DECIMALS } from "./constant";

describe("NativeBank", () => {
    let signers: HardhatEthersSigner[];
    let nativeBankC: NativeBank;

    beforeEach("Depoly NativeBank contract", async () => {
        signers = await hre.ethers.getSigners();
        nativeBankC = await hre.ethers.deployContract("NativeBank");
        
    });
    it("Should send native token to contract", async () => {
        const staker = signers[0];

        const tx = {
            from: staker.address,
            to: await nativeBankC.getAddress(),
            value: hre.ethers.parseEther("1"),
        };
        const txResp = await staker.sendTransaction(tx);
        const txReceipt = await txResp.wait();
        // total balance
        console.log(await hre.ethers.provider.getBalance(await nativeBankC.getAddress()));
        // blanace of staker
        console.log(await nativeBankC.balanceOf(staker.address));
    });

    it("Should withdraw all the tokens", async () => {
        const staker = signers[0];
        const stakingAmount = hre.ethers.parseEther("10");
        const tx = {
            from: staker.address,
            to: await nativeBankC.getAddress(),
            value: stakingAmount,
        }
        const sendTx = await staker.sendTransaction(tx);
        await sendTx.wait();
        expect(await nativeBankC.balanceOf(staker.address)).equal(stakingAmount);

        await nativeBankC.withdraw();
        expect(await nativeBankC.balanceOf(staker.address)).equal(0n);
    });

    const unitParser = (amount: string) => hre.ethers.parseUnits(amount, DECIMALS);
    const unitFormatter = (amount: bigint) => hre.ethers.formatUnits(amount, DECIMALS);
    const getBalance = async (address: string) => unitFormatter(await hre.ethers.provider.getBalance(address));
    it("exploit", async () => {
        const victim1 = signers[1];
        const victim2 = signers[2];
        const hacker = signers[3];

        const exploitC = await hre.ethers.deployContract("Exploit", [await nativeBankC.getAddress()], hacker);
        const hCAddr = await exploitC.getAddress();
        const stakingAmount = unitParser("1");
        const v1Tx = {
            from: victim1.address,
            to: await nativeBankC.getAddress(),
            value: stakingAmount
        }
        const v2Tx = {
            from: victim2.address,
            to: await nativeBankC.getAddress(),
            value: stakingAmount
        }
        await victim1.sendTransaction(v1Tx);
        await victim2.sendTransaction(v2Tx);

        await getBalance(hCAddr);
        await exploitC.exploit({value: stakingAmount}); // no params, field of transaction
        await getBalance(hCAddr);
    });
});
