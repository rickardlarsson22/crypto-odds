const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("My Betting Dapp", function () {
  let Bet;

  // quick fix to let gas reporter fetch data from gas station & coinmarketcap
  before((done) => {
    setTimeout(done, 2000);
  });

  describe("bet", function () {
    it("Should deploy bet", async function () {
      const bet = await ethers.getContractFactory("bet");

      Bet = await bet.deploy();
    });
  });
});
