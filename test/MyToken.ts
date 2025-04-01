import hre from "hardhat";
import { expect } from "chai";

describe("MyToken", () => {
    let myTokenC: any;

    before(async () => {
        myTokenC = await hre.ethers.deployContract("MyToken", ["MyToken", "MT", 18]);
    });

    it("should have the correct name", async () => {
        expect(await myTokenC.name()).equal("MyToken");
    });

    it("should have the correct symbol", async () => {
        expect(await myTokenC.symbol()).equal("MT");
    });

    it("should have the correct decimals", async () => {
        expect(await myTokenC.decimals()).equal(18);
    });
});