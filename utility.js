const sha3 = require('web3/lib/utils/sha3.js');
const sha256 = require('js-sha256').sha256;
const Tx = require('ethereumjs-tx');
const ethUtil = require('ethereumjs-util');
const BigNumber = require('bignumber.js');

module.exports = (config) => {
  const utility = {};

  utility.sign = function sign(address, msgToSignIn, privateKeyIn, callback) {
    let msgToSign = msgToSignIn;
    if (msgToSign.substring(0, 2) !== '0x') msgToSign = `0x${msgToSign}`;

    function prefixMessage(msgIn) {
      let msg = msgIn;
      msg = new Buffer(msg.slice(2), 'hex');
      msg = Buffer.concat([
        new Buffer(`\x19Ethereum Signed Message:\n${msg.length.toString()}`),
        msg
      ]);
      //console.log('MSG TO BE HASHED 1', msg.toString('hex'));

      msg = sha3(`0x${msg.toString('hex')}`, {
        encoding: 'hex'
      });
      msg = new Buffer((msg.substring(0, 2) === '0x') ? msg.slice(2) : msg, 'hex');
      return `0x${msg.toString('hex')}`;
    }

    function testSig(msg, sig) {
      const recoveredAddress =
        `0x${ethUtil.pubToAddress(ethUtil.ecrecover(msg, sig.v, sig.r, sig.s)).toString('hex')}`;
      return recoveredAddress === address;
    }
    //if (privateKeyIn) {
    let privateKey = privateKeyIn;
    if (privateKey.substring(0, 2) === '0x') privateKey = privateKey.substring(2, privateKey.length);
    msgToSign = prefixMessage(msgToSign);
    try {
      const sig = ethUtil.ecsign(
        new Buffer(msgToSign.slice(2), 'hex'),
        new Buffer(privateKey, 'hex'));
      const r = `0x${sig.r.toString('hex')}`;
      const s = `0x${sig.s.toString('hex')}`;
      const v = sig.v;
      const result = {
        r,
        s,
        v
      };
      callback(undefined, result);
    } catch (err) {
      callback(err, undefined);
    }
   
  };

  utility.verify = function verify(addressIn, // eslint-disable-line consistent-return
    v, rIn, sIn, valueIn, callback) {
    const address = addressIn.toLowerCase();
    let r = rIn;
    let s = sIn;
    let value = valueIn;
    if (r.substring(0, 2) === '0x') r = r.substring(2, r.length);
    if (s.substring(0, 2) === '0x') s = s.substring(2, s.length);
    if (value.substring(0, 2) === '0x') value = value.substring(2, value.length);
    const pubKey = ethUtil.ecrecover(
      new Buffer(value, 'hex'),
      Number(v),
      new Buffer(r, 'hex'),
      new Buffer(s, 'hex'));
    const result = address === `0x${ethUtil.pubToAddress(new Buffer(pubKey, 'hex')).toString('hex')}`;
    if (callback) {
      callback(undefined, result);
    } else {
      return result;
    }
  };

  utility.signgastankparameters = function(tokenaddress, gastankaddress, gastankclient, take, give, valid_until, random, privatekey) {
    if (privatekey.substring(0, 2) === '0x') privatekey = privatekey.substring(2, privatekey.length);
    const condensed = utility.pack(
      [
        tokenaddress,
        gastankaddress,
        gastankclient,
        take,
        give,
        valid_until,
        random,
      ], [160, 160, 160, 256, 256, 256, 256]);
    const hash = sha256(new Buffer(condensed, 'hex'));
    console.log('tokenaddress', tokenaddress);
    console.log('gastankaddress', gastankaddress);
    console.log('gastankclient', gastankclient);
    console.log('take', take);
    console.log('give', give);
    console.log('valid_until', valid_until);
    console.log('random', random);
    console.log('my hash=', hash);
    const sig = ethUtil.ecsign(
      new Buffer(hash, 'hex'),
      new Buffer(privatekey, 'hex'));
    const r = `0x${sig.r.toString('hex')}`;
    const s = `0x${sig.s.toString('hex')}`;
    const v = sig.v;
    const result = {
      r,
      s,
      v
    };
    return result;
  };


  utility.getapprovaltx = function(web3, from, from_pk, token_address, tokenamount, to, gasprice, cb) {

    var minime = web3.eth.contract(IMiniMeToken.abi);
    var minimeInstance = minime.at(token_address);

    // minimeInstance.balanceOf(this.address, function(err, res) {
    //   console.log('SWT balance is', res.toFormat(2));
    //   self.tokenbalance = res;
    // });

    console.log('sending approval from ', from, 'for ', tokenamount, 'to', to);

    var txData = minimeInstance.approve.getData(to, tokenamount);

    web3.eth.estimateGas({
      to: token_address,
      data: txData,
      from: from
    }, function(err, res) {
      if (err) {
        return cb(err);
      }
      var gasRequired = res;

      // get nonce
      web3.eth.getTransactionCount(from, function(err, nonce) {

        if (!nonce) {
          nonce = 0;
        }

        var txParams = {
          nonce: nonce++,
          gasPrice: gasprice,
          gasLimit: gasRequired,
          to: token_address,
          from: from,
          data: txData,
          chainId: 1
        };

        var tx = new Tx(txParams);
        tx.sign(new Buffer(from_pk.slice(2), 'hex'));

        //var serializedTx = tx.serialize();

        return cb(null, {
          signedtx: `0x${tx.serialize().toString('hex')}`,
          cost: txParams.gasPrice * txParams.gasLimit
        });


      });

    });

    //    return txData;

  };

  utility.zeroPad = function zeroPad(num, places) {
    const zero = (places - num.toString().length) + 1;
    return Array(+(zero > 0 && zero)).join('0') + num;
  };

  utility.decToHex = function decToHex(dec, lengthIn) {
    let length = lengthIn;
    if (!length) length = 32;
    if (dec < 0) {
      // return convertBase((Math.pow(2, length) + decStr).toString(), 10, 16);
      return (new BigNumber(2)).pow(length).add(new BigNumber(dec)).toString(16);
    }
    let result = null;
    try {
      result = utility.convertBase(dec.toString(), 10, 16);
    } catch (err) {
      result = null;
    }
    if (result) {
      return result;
    }
    return (new BigNumber(dec)).toString(16);
  };

  utility.pack = function pack(dataIn, lengths) {
    let packed = '';
    const data = dataIn.map(x => x);
    for (let i = 0; i < lengths.length; i += 1) {
      if (typeof(data[i]) === 'string' && data[i].substring(0, 2) === '0x') {
        if (data[i].substring(0, 2) === '0x') data[i] = data[i].substring(2);
        packed += utility.zeroPad(data[i], lengths[i] / 4);
      } else if (typeof(data[i]) !== 'number' && /[a-f]/.test(data[i])) {
        if (data[i].substring(0, 2) === '0x') data[i] = data[i].substring(2);
        packed += utility.zeroPad(data[i], lengths[i] / 4);
      } else {
        // packed += zeroPad(new BigNumber(data[i]).toString(16), lengths[i]/4);
        packed += utility.zeroPad(utility.decToHex(data[i], lengths[i]), lengths[i] / 4);
      }
    }
    return packed;
  };

  utility.convertBase = function convertBase(str, fromBase, toBase) {
    const digits = utility.parseToDigitsArray(str, fromBase);
    if (digits === null) return null;
    let outArray = [];
    let power = [1];
    for (let i = 0; i < digits.length; i += 1) {
      if (digits[i]) {
        outArray = utility.add(outArray,
          utility.multiplyByNumber(digits[i], power, toBase), toBase);
      }
      power = utility.multiplyByNumber(fromBase, power, toBase);
    }
    let out = '';
    for (let i = outArray.length - 1; i >= 0; i -= 1) {
      out += outArray[i].toString(toBase);
    }
    if (out === '') out = 0;
    return out;
  };

  utility.parseToDigitsArray = function parseToDigitsArray(str, base) {
    const digits = str.split('');
    const ary = [];
    for (let i = digits.length - 1; i >= 0; i -= 1) {
      const n = parseInt(digits[i], base);
      if (isNaN(n)) return null;
      ary.push(n);
    }
    return ary;
  };

  utility.add = function add(x, y, base) {
    const z = [];
    const n = Math.max(x.length, y.length);
    let carry = 0;
    let i = 0;
    while (i < n || carry) {
      const xi = i < x.length ? x[i] : 0;
      const yi = i < y.length ? y[i] : 0;
      const zi = carry + xi + yi;
      z.push(zi % base);
      carry = Math.floor(zi / base);
      i += 1;
    }
    return z;
  };

  utility.multiplyByNumber = function multiplyByNumber(numIn, x, base) {
    let num = numIn;
    if (num < 0) return null;
    if (num === 0) return [];
    let result = [];
    let power = x;
    while (true) { // eslint-disable-line no-constant-condition
      if (num & 1) { // eslint-disable-line no-bitwise
        result = utility.add(result, power, base);
      }
      num = num >> 1; // eslint-disable-line operator-assignment, no-bitwise
      if (num === 0) break;
      power = utility.add(power, power, base);
    }
    return result;
  };

  return utility;
};
