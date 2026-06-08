    import hre from "hardhat";

async function main() {
  const RecipeContest = await hre.ethers.getContractFactory("RecipeContest");
  const recipeContest = await RecipeContest.deploy();

  await recipeContest.waitForDeployment();

  console.log("RecipeContest deployed to:", await recipeContest.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});