import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomiclabs/hardhat-vyper";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  vyper: {
    version: "0.3.0",
  },
  networks: {
    kairos: {
      url: "https://public-en-kairos.node.kaia.io",
      accounts: ["0x9f3e862e160f4340ae7744ec3ddc47ab4371a46c5de7680580ac82513c44d3bc"] // kairos toolkit private key, faucet
    }
  },
  etherscan: {
      apiKey: {
        kairos: "unnecessary",
      },
      customChains: [
        {
          network: "kairos",
          chainId: 1001,
          urls: {
            apiURL: "https://kairos-api.kaiascan.io/hardhat-verify",
            browserURL: "https://kairos.kaiascan.io",
          }
        },
      ]
    }
};

export default config;
