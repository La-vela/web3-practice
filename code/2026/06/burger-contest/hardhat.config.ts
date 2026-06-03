import { HardhatUserConfig } from "hardhat/config";

// 전체 툴박스 대신, 가장 핵심인 ethers 플러그인만 직접 불러오기

import "@nomicfoundation/hardhat-ethers"; 
import "@nomicfoundation/hardhat-chai-matchers";

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  }
};

export default config;