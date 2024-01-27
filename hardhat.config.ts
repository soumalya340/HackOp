require("dotenv").config();
import dotenv from "dotenv";
dotenv.config();
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-truffle5";
import "@nomiclabs/hardhat-waffle";
import "hardhat-gas-reporter";
import "solidity-coverage";

import "@typechain/hardhat";
import "@nomiclabs/hardhat-ethers";

import { task } from "hardhat/config";

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// TESTNET
const MATICMUM_RPC_URL =
  process.env.MATICMUM_RPC_URL ||
  "https://polygon-mumbai.g.alchemy.com/v2/api-key";
const OPTIMISM_GOERLI_RPC_URL =
  process.env.OPTIMISM_GOERLI_RPC_URL ||
  "https://optimism-goerli.infura.io/v3/api-key";
const OPTIMISM_RPC_URL =
  process.env.OPTIMISM_RPC_URL ||
  "https://filecoin-mainnet.chainstacklabs.com/rpc/v1";

const MNEMONIC =
  process.env.MNEMONIC ||
  "ajkskjfjksjkf ssfaasff asklkfl klfkas dfklhao asfj sfk klsfjs fkjs";
const PRIVATE_KEY = process.env.PRIVATE_KEY;

const POLYGONSCAN_API_KEY =
  process.env.POLYGONSCAN_API_KEY || "lklsdkskldjklgdklkld";
const OPTISCAN_API_KEY = process.env.OPTISCAN_API_KEY || "Optiscan API Key";

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.20",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      initialBaseFeePerGas: 0,
    },
    // TESTNET NETWORKS
    maticmum: {
      networkId: 80001,
      url: MATICMUM_RPC_URL,
      // accounts: [PRIVATE_KEY],
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
    optiGoerli: {
      networkId: 420,
      url: OPTIMISM_GOERLI_RPC_URL,
      accounts: [PRIVATE_KEY],
      // accounts: {
      //   mnemonic: MNEMONIC,
      // },
    },
    optimism: {
      networkId: 10,
      url: OPTIMISM_RPC_URL,
      // accounts : [PRIVATE_KEY],
      accounts: {
        mnemonic: MNEMONIC,
      },
    },
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: {
      polygonMumbai: POLYGONSCAN_API_KEY,
      optimisticGoerli: OPTISCAN_API_KEY,
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts",
  },
  mocha: {
    timeout: 20000,
  },
};
