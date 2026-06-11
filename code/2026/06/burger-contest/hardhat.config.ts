import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

// .env 파일을 불러오는 코드입니다.
dotenv.config();

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.28",
    settings: {
      evmVersion: "cancun",
    },
  },
  networks: {
    sepolia: {
      // Alchemy에서 복사한 주소를 여기서 가져옵니다.
      url: process.env.RPC_URL || "", 
      // 메타마스크 개인키를 여기서 가져옵니다. .env에 없으면 빈 배열 사용.
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
  },
};

export default config;
