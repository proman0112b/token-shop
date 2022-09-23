async function main() {
  console.log('Preparing deployment... \n')
  // Fetch contract to deploy
  const Token = await ethers.getContractFactory("Token")

  // Fetch accounts
  const accounts = await ethers.getSigners();
  console.log(`Accounts fetched:\n${accounts[0].address}\n`)


  // Deploy contracts
  const coo = await Token.deploy()
  await coo.deployed()
  let symbol = await coo.symbol()
  console.log(symbol)
  console.log(`coo Deployed to: ${coo.address}`)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
