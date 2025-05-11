import hre from "hardhat";

describe("NativeBank", () => {
    it("Should send native token to contract", async () => {
        const singers = await hre.ethers.getSigners();
        const staker = singers[0];
        const nativeBankC = await hre.ethers.deployContract("NativeBank");

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
});