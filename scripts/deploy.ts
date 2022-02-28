import { artifacts } from "hardhat";

async function main() {
  const StakingToken = artifacts.require("StakingToken");
  const contract = await StakingToken.new();

  console.log("StakingToken deployed to:", contract.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
