const SampleERC20 = artifacts.require("./SampleERC20.sol");
const HomeERC20Bridge = artifacts.require("./HomeERC20Bridge");
const ForeignERC777Bridge = artifacts.require("./ForeignERC777Bridge.sol");
const SidechainToken = artifacts.require("eip777/contracts/SidechainToken.sol");

const EIP820 = require('eip820');
const erc777 = artifacts.require("eip777/contracts/ReferenceToken.sol");

const keythereum = require('keythereum');
const ethUtil = require('ethereumjs-util');
const utility = require('../utility.js')();
const sha256 = require('js-sha256').sha256;


contract('SampleERC20/ERC777', (accounts) => {

	// HOMECHAIN
	// the ERC20 token on the home chain
	let homeToken;
	let homeTokenOwner = accounts[1];

	let bridgeOwner = accounts[2];

	// the HomeERC20Bridge contract
	let homeERC20Bridge;
	const requiredValidators = 3;

	// Alice : the sender
	let alice = accounts[3];
	let aliceAmount = 10e18;

	// SIDECHAIN
	// the ForeignERC777Bridge contract
	let foreignERC777Bridge;

	let sidechainToken;

	// validator set
	let validators = [];

	// inverse test
	let nonValidators = [];

	gasStats = [];

	function mkkeypair() {
		var dk = keythereum.create();
		var keyObject = keythereum.dump("none", dk.privateKey, dk.salt, dk.iv);
		return ({
			private: dk.privateKey.toString('hex'),
			public: ethUtil.addHexPrefix(keyObject.address)
		});
	}

	function collectGasStats(transactionHash, description, cb) {
		web3.eth.getTransactionReceipt(transactionHash, function(e, tx) {
			gasStats.push({
				name: description,
				gasUsed: tx.gasUsed
			})
			if (cb) cb();
		});
	}

	describe('HomeChain setup', () => {

		it('generate 10 validator keys', () => {
			for (let i = 0; i < 10; i++) {
				validators.push(mkkeypair());
			}
		});

		it('generate 2 invalid validator keys', () => {
			for (let i = 0; i < 10; i++) {
				nonValidators.push(mkkeypair());
			}
		});

		it("deploys SampleERC20coin", (done) => {
			SampleERC20.new({
				from: homeTokenOwner
			}).then(function(_instance) {
				assert.ok(_instance.address);
				homeToken = _instance;
				collectGasStats(_instance.transactionHash, 'deploys SampleERC20coin', done);
			});
		});

		it("mints SampleERC20coin to alice", (done) => {
			homeToken.mint(alice, aliceAmount, {
				from: homeTokenOwner
			}).then(function() {
				done();
			});
		});

		it("deploys HomeERC20Bridge", (done) => {
			let validatorpubkeys = validators.reduce((accumulator, currentValue) => {
				accumulator.push(currentValue.public);
				return accumulator;
			}, []);
			console.log(validatorpubkeys);
			HomeERC20Bridge.new(3, validatorpubkeys, {
				from: bridgeOwner
			}).then(function(_instance) {
				assert.ok(_instance.address);
				homeERC20Bridge = _instance;
				done();
			});
		});

		// it("registers validators on HomeERC20Bridge", async () => {
		// 	for (let i = 0; i < validators.length; i++) {
		// 		await homeERC20Bridge.addValidator(validators[i].public, {
		// 			from: bridgeOwner
		// 		});
		// 	}
		// });
	});

	// describe('Deposit test', () => {
	// 	it("sends tokens to the HomeERC20Bridge", (done) => {
	// 		homeToken.transfer(homeERC20Bridge.address, 1, {
	// 			from: alice
	// 		}).then(function() {
	// 			done();
	// 		});
	// 	});
	// });

	// describe('Withdraw test', () => {
	// 	it("should withdraw tokens from HomeERC20Bridge back to tokenOwner", (done) => {
	// 		homeERC20Bridge.withdraw(homeToken.address, homeTokenOwner, 1, {
	// 			from: alice
	// 		}).then(function() {
	// 			done();
	// 		});
	// 	});
	// });

	describe('ForeignChain setup', () => {

		it("deploys the EIP820 registry", async () => {
			await web3.eth.sendTransaction({
				from: bridgeOwner,
				to: "0xc253917a2b4a2b7f43286ae500132dae7dc22459",
				value: 1e17
			});
			// see deploy notes : https://github.com/ethereum/EIPs/issues/820
			await web3.eth.sendRawTransaction('0xf9051b8085174876e800830c35008080b904c86060604052341561000f57600080fd5b6104aa8061001e6000396000f30060606040526004361061006c5763ffffffff7c010000000000000000000000000000000000000000000000000000000060003504166329965a1d81146100715780633d5840631461009c5780635df8122f146100d757806365ba36c1146100fc578063aabbb8ca1461015f575b600080fd5b341561007c57600080fd5b61009a600160a060020a036004358116906024359060443516610181565b005b34156100a757600080fd5b6100bb600160a060020a03600435166102ec565b604051600160a060020a03909116815260200160405180910390f35b34156100e257600080fd5b61009a600160a060020a0360043581169060243516610338565b341561010757600080fd5b61014d60046024813581810190830135806020601f820181900481020160405190810160405281815292919060208401838380828437509496506103f395505050505050565b60405190815260200160405180910390f35b341561016a57600080fd5b6100bb600160a060020a0360043516602435610458565b8233600160a060020a0316610195826102ec565b600160a060020a0316146101a857600080fd5b600160a060020a038216158015906101d2575033600160a060020a031682600160a060020a031614155b156102735781600160a060020a031663f008325085856000604051602001526040517c010000000000000000000000000000000000000000000000000000000063ffffffff8516028152600160a060020a0390921660048301526024820152604401602060405180830381600087803b151561024d57600080fd5b6102c65a03f1151561025e57600080fd5b50505060405180519050151561027357600080fd5b600160a060020a0384811660008181526020818152604080832088845290915290819020805473ffffffffffffffffffffffffffffffffffffffff191693861693841790558591907f93baa6efbd2244243bfee6ce4cfdd1d04fc4c0e9a786abd3a41313bd352db153905160405180910390a450505050565b600160a060020a038082166000908152600160205260408120549091161515610316575080610333565b50600160a060020a03808216600090815260016020526040902054165b919050565b8133600160a060020a031661034c826102ec565b600160a060020a03161461035f57600080fd5b82600160a060020a031682600160a060020a03161461037e5781610381565b60005b600160a060020a0384811660008181526001602052604090819020805473ffffffffffffffffffffffffffffffffffffffff191694841694909417909355908416917f605c2dbf762e5f7d60a546d42e7205dcb1b011ebc62a61736a57c9089d3a4350905160405180910390a3505050565b6000816040518082805190602001908083835b602083106104255780518252601f199092019160209182019101610406565b6001836020036101000a038019825116818451161790925250505091909101925060409150505180910390209050919050565b600160a060020a03918216600090815260208181526040808320938352929052205416905600a165627a7a72305820b34bad64d26ce55bab1c48c59eb70737ab782b820d0f1ed6e2f6d6780d62dec300291ba079be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798a00aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa');
		});

		it("deploys ForeignERC777Bridge", (done) => {
			let validatorpubkeys = validators.reduce((accumulator, currentValue) => {
				accumulator.push(currentValue.public);
				return accumulator;
			}, []);
			console.log(validatorpubkeys);
			ForeignERC777Bridge.new(3, validatorpubkeys, {
				from: bridgeOwner
			}).then(function(_instance) {
				assert.ok(_instance.address);
				foreignERC777Bridge = _instance;
				done();
			});
		});

		it("creates the Sidechain token", async () => {
			const name = await homeToken.name();
			const symbol = await homeToken.symbol();

			sidechainToken = await SidechainToken.new(foreignERC777Bridge.address, name, symbol, 1, {
				from: bridgeOwner,
			});

			// set the ownership of the token to the bridge - otherwise we cannot mint tokens.. :(
			await sidechainToken.changeOwnership(foreignERC777Bridge.address, {
				from: bridgeOwner,
			});

		});

		it("registers the mapping from main->sidechain token", async () => {
			console.log('added mapping', homeToken.address, '=>', sidechainToken.address);
			await foreignERC777Bridge.registerToken(homeToken.address, sidechainToken.address, {
				from: bridgeOwner,
			});
		});


	});

	describe('Cross the bridge: main -> side', () => {

		var mintingHash;

		it("sends 1e18 token units to the HomeBridge", (done) => {
			// Alice sends 
			homeToken.transfer(homeERC20Bridge.address, 1e18, {
				from: alice
			}).then(function(tx) {
				//				console.log('HASHIESJ',tx.receipt.transactionHash);
				mintingHash = tx.receipt.transactionHash;
				done();
			});

			// now the validators catch the Transfer event , and mint the token on the
			// foreign network 
		});

		it("creates signatures", async () => {

			const condensed = utility.pack(
				[
					mintingHash,
					homeToken.address,
					alice,
					1e18
				], [256, 160, 160, 256]);
			const hash = sha256(new Buffer(condensed, 'hex'));
			console.log('offchain hash', hash);

			for (let i = 0; i < requiredValidators + 1; i++) {


				const sig = ethUtil.ecsign(
					new Buffer(hash, 'hex'),
					new Buffer(validators[i].private, 'hex'));
				const r = `0x${sig.r.toString('hex')}`;
				const s = `0x${sig.s.toString('hex')}`;
				const v = sig.v;

				console.log('sig', i + 1, r, s, v);
				//console.log(foreignERC777Bridge);

				let t = await foreignERC777Bridge.signMintRequest(mintingHash, homeToken.address, alice, 1e18, v, r, s);
				console.log('txdata', t.logs[0].args);

				let balance = await sidechainToken.balanceOf(alice);
				console.log('balance', balance.toString());
			}
		});


		// it('validators mint new token'){
		// 	// await foreignERC777Bridge.transfer(homeERC20Bridge.address, 2, {
		// 	// 	from: alice
		// 	// });

		// }


	});

	describe('STATS TIME', () => {
		it("dumps", (done) => {
			let cumulative = 0;
			gasStats.forEach(function(item) {
				console.log(item.name, '=>', item.gasUsed, 'gas used');
			})
			done();
		});
	});


});
