const keythereum = require('keythereum');
const ethUtil = require('ethereumjs-util');

function mkkeypair() {
	var dk = keythereum.create();
	var keyObject = keythereum.dump("none", dk.privateKey, dk.salt, dk.iv);
	return ({
		private: dk.privateKey.toString('hex'),
		public: ethUtil.addHexPrefix(keyObject.address)
	});
}

for (let i = 0; i < 10; i++) {
	console.log(JSON.stringify(mkkeypair()));
}
