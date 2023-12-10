import "@nomiclabs/hardhat-ethers";

import { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  networks: {
    mode: {
      url: "https://sepolia.mode.network",
      chainId: 919,
      accounts: ["YOUR_PRIVATE_KEY_HERE"] //BE VERY CAREFUL, DO NOT PUSH THIS TO GITHUB
    }
  },
  solidity: "0.8.0",
};

export default config;