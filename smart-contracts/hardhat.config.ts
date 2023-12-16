import "dotenv/config";
import "@nomicfoundation/hardhat-toolbox";

import { HardhatUserConfig } from "hardhat/config";

const PRIVATE_KEY = process.env.SEPOLIA_PRIVATE_KEY as string

const config: HardhatUserConfig = {
  networks: {
    mode: {
      url: "https://sepolia.mode.network",
      chainId: 919,
      accounts: [PRIVATE_KEY] //BE VERY CAREFUL, DO NOT PUSH THIS TO GITHUB
    }
  },
  solidity: "0.8.20",
};

export default config;