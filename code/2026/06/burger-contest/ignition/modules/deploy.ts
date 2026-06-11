import { ethers } from "hardhat";

async function main() {
  console.log("스마트 컨트랙트 배포를 시작합니다...");

  // 'BurgerContest'는 실제 .sol 파일 내부의 컨트랙트 이름과 일치해야 합니다.
  const BurgerContest = await ethers.getContractFactory("BurgerContest");

  const burgerContest = await BurgerContest.deploy();
  await burgerContest.waitForDeployment();

  const contractAddress = await burgerContest.getAddress();

  console.log("==========================================");
  console.log(`컨트랙트 배포 성공!`);
  console.log(`배포된 주소: ${contractAddress}`);
  console.log("==========================================");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
