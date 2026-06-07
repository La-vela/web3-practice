import { HardhatUserConfig } from "hardhat/config";

// 전체 툴박스 대신, 가장 핵심인 ethers 플러그인만 직접 불러오기

import "@nomicfoundation/hardhat-toolbox";
import type { HardhatUserConfig } from "hardhat/config";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "cancun",
    },
  },
};

export default config;