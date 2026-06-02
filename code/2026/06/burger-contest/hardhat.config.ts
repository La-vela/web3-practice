import { HardhatUserConfig } from "hardhat/config";
// v3에서 ethers를 사용하기 위한 핵심 플러그인
import "@nomicfoundation/hardhat-toolbox-mocha-ethers"; 

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  // v3의 새로운 설정 방식을 유지하고 싶다면 아래 구조를 사용하세요.
  // 하지만 테스트 안정성을 위해 일단 기본 구조로 제안드립니다.
};

export default config;