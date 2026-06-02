import { expect } from "chai";
import { ethers } from "hardhat";

describe("RecipeContest", function () {
  // 공통 배포 로직
  async function deployFixture() {
    const [owner, user1] = await ethers.getSigners();
    const RecipeContest = await ethers.getContractFactory("RecipeContest");
    const recipeContest = await RecipeContest.deploy();
    return { recipeContest, owner, user1 };
  }

  it("레시피 제출부터 민팅까지의 전체 워크플로우 테스트", async function () {
    const { recipeContest, user1 } = await deployFixture();

    // 1. 레시피 제출 (user1)
    await recipeContest
      .connect(user1)
      .submitRecipe("Double Cheese Burger", "ipfs://burger-image");
    let recipe = await recipeContest.recipes(1);
    expect(recipe.name).to.equal("Double Cheese Burger");
    expect(recipe.status).to.equal(0); // PENDING

    // 2. 관리자가 승인 (owner)
    await recipeContest.approveRecipe(1);
    recipe = await recipeContest.recipes(1);
    expect(recipe.status).to.equal(1); // APPROVED

    // 3. 관리자가 민팅 (owner)
    const mintAmount = 100;
    await recipeContest.mintRecipe(1, mintAmount);
    recipe = await recipeContest.recipes(1);
    expect(recipe.status).to.equal(3); // MINTED
    expect(recipe.tokenId).to.equal(1);

    // 4. 최종 결과 확인: user1이 100개의 토큰을 가졌는지 확인
    const balance = await recipeContest.balanceOf(user1.address, 1);
    expect(balance).to.equal(mintAmount);
  });

  it("승인되지 않은 레시피는 민팅할 수 없어야 함", async function () {
    const { recipeContest, user1 } = await deployFixture();
    await recipeContest
      .connect(user1)
      .submitRecipe("Single Burger", "ipfs://single");

    // 승인 없이 바로 민팅 시도 -> 에러 발생 기대
    await expect(recipeContest.mintRecipe(1, 10)).to.be.revertedWith(
      "Recipe must be approved first",
    );
  });
});
