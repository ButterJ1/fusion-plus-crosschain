// hardhat.config.ts
import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@nomicfoundation/hardhat-verify";
import "dotenv/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 11155111
    },
    dogechain: {
      url: "https://rpc-testnet.dogechain.dog",
      accounts: process.env.PRIVATE_KEY ? [process.env.PRIVATE_KEY] : [],
      chainId: 568
    }
  },
  etherscan: {
    apiKey: {
      sepolia: process.env.ETHERSCAN_API_KEY || "",
      dogechain: "abc" // DogeChain doesn't require API key
    },
    customChains: [
      {
        network: "dogechain",
        chainId: 568,
        urls: {
          apiURL: "https://explorer-testnet.dogechain.dog/api",
          browserURL: "https://explorer-testnet.dogechain.dog"
        }
      }
    ]
  }
};

export default config;