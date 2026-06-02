import { expect } from "chai";
import hre from "hardhat";

describe("RecipeContest", function () {
  const { ethers } = hre;

  // 공통 배포 로직 (Fixture)
  async function deployFixture() {
    // 가상 지갑 주소 가져오기 (owner: 관리자, user1: 참여자)
    const [owner, user1] = await ethers.getSigners();

    // 컨트랙트 팩토리 로드 및 배포
    const RecipeContest = await ethers.getContractFactory("RecipeContest");
    const recipeContest = await RecipeContest.deploy();

    return { recipeContest, owner, user1 };
  }

  it("레시피 제출부터 승인, 민팅까지의 전체 워크플로우 테스트", async function () {
    const { recipeContest, user1 } = await deployFixture();

    // 1. 레시피 제출 (user1이 실행)
    const tx = await recipeContest.connect(user1).submitRecipe(
      "Triple Cheese Burger", 
      "ipfs://burger-metadata-uri"
    );
    await tx.wait(); // 트랜잭션 확정 대기

    // 상태 확인 (0: PENDING)
    let recipe = await recipeContest.recipes(1);
    expect(recipe.name).to.equal("Triple Cheese Burger");
    expect(recipe.status).to.equal(0); 

    // 2. 관리자(owner)가 레시피 승인
    await recipeContest.approveRecipe(1);
    recipe = await recipeContest.recipes(1);
    expect(recipe.status).to.equal(1); // 1: APPROVED

    // 3. 관리자(owner)가 실제 NFT 발행 (100개)
    const mintAmount = 100;
    await recipeContest.mintRecipe(1, mintAmount);
    
    recipe = await recipeContest.recipes(1);
    expect(recipe.status).to.equal(3); // 3: MINTED
    expect(recipe.tokenId).to.equal(1);

    // 4. 최종 결과 확인: 제출자(user1)의 지갑에 토큰이 들어왔는지 확인
    const userBalance = await recipeContest.balanceOf(user1.address, 1);
    expect(userBalance).to.equal(mintAmount);
  });

  it("거절(Reject) 기능이 정상적으로 작동해야 함", async function () {
    const { recipeContest, user1 } = await deployFixture();

    await recipeContest.connect(user1).submitRecipe("Bad Burger", "ipfs://bad");
    
    // 관리자가 거절 실행
    await recipeContest.rejectRecipe(1);
    const recipe = await recipeContest.recipes(1);
    expect(recipe.status).to.equal(2); // 2: REJECTED
  });

  it("승인되지 않은 레시피를 민팅하려고 하면 에러가 발생해야 함", async function () {
    const { recipeContest, user1 } = await deployFixture();
    await recipeContest.connect(user1).submitRecipe("Normal Burger", "ipfs://normal");

    // 승인 없이 바로 민팅 시도 시 revert(에러) 발생 확인
    await expect(recipeContest.mintRecipe(1, 10))
      .to.be.revertedWith("Recipe must be approved first");
  });
});