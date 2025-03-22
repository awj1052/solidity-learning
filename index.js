const ethers = require("ethers");

async function main() {
    console.log(ethers.getAddress());
    
    // const myFirstWalet = ethers.Wallet.createRandom();
    // // console.log(myFirstWalet.address);
    // // console.log(myFirstWalet.privateKey);
    // // console.log(myFirstWalet.publicKey);

    // const signedMsg = await myFirstWalet.signMessage("Hello Blockchain");
    // const signer = ethers.verifyMessage("Hello Blockchain", signedMsg);
    // console.log(signer, myFirstWalet.address);
}

main();