pragma solidity ^0.4.18;

import 'eip777/contracts/ITokenRecipient.sol';
import 'eip777/contracts/ReferenceToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validatable.sol';
import './Bridgeable.sol';

contract ForeignERC777Bridge is Ownable, Validatable {

	mapping(bytes32=>uint8) mintRequests;
	mapping(bytes32=>bool) mintRequestsDone;

	mapping(bytes32=>uint8) withdrawRequests;
	mapping(address=>bool) validators;

	// maps home token addresses -> foreign token addresses
	mapping(address=>address) tokenMap;

	event WithdrawRequest(address _to,uint256 _amount,bytes32 _withdrawhash);
	event TokenAdded(address _mainToken,address _sideToken);
	event MintRequestSigned(bytes32 _mintRequestsHash, bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint8 _requiredSignatures,uint8 _signatureCount);
	event MintRequestExecuted(bytes32 _mintRequestsHash, bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount);

	event WithdrawRequestSigned(bytes32 _withdrawRequestsHash, bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint256 _withdrawBlock,address _signer, uint8 _v, bytes32 _r, bytes32 _s);

	function ForeignERC777Bridge(uint8 _requiredValidators,address[] _initialValidators) Validatable(_requiredValidators,_initialValidators) public {
		// deploy a sidechain ETH token as an ERC-777.
		address t = new ReferenceToken('sidechain ETH','sETH',1);
		assert(t != 0x0);
		tokenMap[0x0] = t;
	}

	function registerToken(address _mainToken,address _sideToken) public onlyOwner {
		assert(tokenMap[_mainToken] == 0);
		tokenMap[_mainToken] = _sideToken;
		TokenAdded(_mainToken,_sideToken);
	}

	function signMintRequest(bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint8 _v, bytes32 _r, bytes32 _s) public {
		bytes32 mintRequestsHash = sha256(_transactionHash,_mainToken,_recipient,_amount);
		assert(isValidator(ecrecover(mintRequestsHash, _v, _r, _s)));
		if (mintRequests[mintRequestsHash] < requiredValidators){
			mintRequests[mintRequestsHash]++;
			MintRequestSigned(mintRequestsHash,_transactionHash, _mainToken,  _recipient, _amount,requiredValidators,mintRequests[mintRequestsHash]);
		}else{
			assert(mintRequestsDone[mintRequestsHash] != true);
			assert(tokenMap[_mainToken] != 0x0);
			mintRequestsDone[mintRequestsHash] = true;
			MintRequestExecuted(mintRequestsHash,_transactionHash, tokenMap[_mainToken],  _recipient, _amount);
			Bridgeable(tokenMap[_mainToken]).mintFromBridge(_recipient,_amount,'');
		}
	}

	function signWithdrawRequest(bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint256 _withdrawBlock,uint8 _v, bytes32 _r, bytes32 _s) public {
		bytes32 withdrawRequestsHash = sha256(_mainToken,_recipient,_amount,_withdrawBlock);
		address validator = ecrecover(withdrawRequestsHash, _v, _r, _s);
		assert(isValidator(validator));		
		WithdrawRequestSigned(withdrawRequestsHash,_transactionHash, _mainToken,  _recipient, _amount,_withdrawBlock,validator,_v,_r,_s);
	}


}

