<script>
	import { ethers } from 'ethers';
	import Token from '../artifacts/contracts/OxyDjinn.sol/Token.json';

  const address = "0x5fbdb2315678afecb367f032d93f642f64180aa3"; // Enviroment variable/OxyDjinn token
	let name, symbol, ethPrice;
  let amount = 0;
	let cooPrice = 0 ;

	const provider = new ethers.providers.JsonRpcProvider(); //Localhost provider/connection to the blockchain(read only)
	const contractCo = new ethers.Contract(address, Token.abi, provider)
	let hardhat1 = new ethers.Wallet( "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80", provider )
	let hardhat2 = "0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

	// Coingecko API for Eth price in USD.
	async function getEthPrice() {
		const response = await fetch('https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&order=market_cap_desc&per_page=100&page=1&sparkline=false');
		const obj = await response.json();
		console.log('Etherium', obj[1].current_price)
		ethPrice = obj[1].current_price;
		return obj[1].current_price
	}

	let promise = getEthPrice();

	// Handle the fetch promise for reactive HTML
	function handleClick() {
		promise = getEthPrice()
		console.log(cooPrice, log)
	}

	// Check transfers from the current block - 10 to the current block
	async function checkTransfers() {
		const block = await provider.getBlockNumber()
		const transferEvents = await contractCo.queryFilter('Transfer', block - 10, block)
		const last = transferEvents[transferEvents.length - 1]
		const lastValue = await last.args[2].toString();
		console.log(last.transactionHash, lastValue/1000000000000000000)
	}

	// Request MetaMask provider and fetch the signer.
	async function getSigner() {

		let provider = new ethers.providers.Web3Provider(window.ethereum)
		// MetaMask requires requesting permission to connect users accounts
		await provider.send("eth_requestAccounts", []);

		let signer = provider.getSigner()
		console.log('Connected MetaMask!', provider)
		return signer;
	}
	// Send ether to OxyDjinn
	async function chargeEther (etherPrice) {

		const signer = await getSigner();
		console.log(signer)
		const tx = signer.sendTransaction({
			to: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
			value: ethers.utils.parseEther(parseInt(etherPrice))
		});
		const results = tx.wait()
		console.log(results)
		return(results)
	}

	// Fetch token contract from the blockchain.
	async function sendTokens(_cooPrice) {
		cooPrice = _cooPrice;
		await chargeEther(_cooPrice);


		const oxyDjinnContract = new ethers.Contract(address, Token.abi, hardhat1)
		name = await oxyDjinnContract.name()
		symbol = await oxyDjinnContract.symbol()

		const oxyDjinnConnection = oxyDjinnContract.connect(hardhat1);
		const coo = ethers.utils.parseUnits(amount.toString(), 18);
		amount = 0;

		const tx = await oxyDjinnConnection.transfer(hardhat2, coo);
		const results = await tx.wait()
		const bigNumber = results.events[0].args[2]
		console.log('Transaction sent!', results.events[0].transactionHash, bigNumber.toString()/1000000000000000000)
		checkTransfers()
	}

	async function sendEther () {
		let provider = new ethers.providers.Web3Provider(window.ethereum)
		// MetaMask requires requesting permission to connect users accounts
		await provider.send("eth_requestAccounts", []);

		let signer = provider.getSigner()
		console.log('Connected MetaMask!', provider)

		const tx = await signer.sendTransaction({
			to: "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266",
			value: ethers.utils.parseEther('1')
		});
		const results = await tx.wait()
		console.log(results)
	}



</script>

<main>

	<div>
		<button on:click={getSigner}>Connect MetaMask</button>
	</div>
	<h2>
		The name of the token is:'{name}' and the symbol is '{symbol}'
	</h2>
	<div>
		<input bind:value={amount} placeholder="Set amount of COO to buy">
	</div>

	<button on:click={handleClick}>
		Fetch Etherium's current Price
	</button>
	{#await promise then }
	<h2>The price of Etherium is: {ethPrice}</h2>
	<h2>The price of COO in Eth is: {amount/ethPrice}</h2>
	<button on:click={sendEther}>Buy Tokens with Eth</button>
	{:catch error}
	onpopstate. something's wrong
	{/await}

	<h1>Last bought COO at price: {cooPrice}</h1>
</main>

<style>
	main {
		text-align: center;
		padding: 1em;
		max-width: 240px;
		margin: 0 auto;
	}

	@media (min-width: 640px) {
		main {
			max-width: none;
		}
	}
</style>
