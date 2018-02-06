pragma solidity ^0.4.18;

import 'eip777/contracts/ITokenRecipient.sol';
import 'eip777/contracts/ReferenceToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validatable.sol';
import './Bridgable.sol';

contract ForeignERC777Bridge is Ownable, Validatable {

	mapping(bytes32=>uint8) mintRequests;
	mapping(bytes32=>bool) mintRequestsDone;

	mapping(bytes32=>uint8) withdrawRequests;
	mapping(address=>bool) validators;

	// maps home token addresses -> foreign token addresses
	mapping(address=>address) tokenMap;

	event WithdrawRequest(address _to,uint256 _amount,bytes32 _withdrawhash);
	event TokenAdded(address _homeAddress,address _sideAddress);
	event MintRequestSigned(bytes32 _mintRequestsHash, bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint8 _requiredSignatures,uint8 _signatureCount);
	event MintRequestExecuted(bytes32 _mintRequestsHash, bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount);

	function ForeignERC777Bridge(uint8 _requiredValidators,address[] _initialValidators) Validatable(_requiredValidators,_initialValidators) public {
		// deploy a sidechain ETH token as an ERC-777.
		address t = new ReferenceToken('sidechain ETH','sETH',1);
		assert(t != 0x0);
		tokenMap[0x0] = t;
	}

	function registerToken(address _homeAddress,address _sideAddress) public onlyOwner {
		assert(tokenMap[_homeAddress] == 0);
		tokenMap[_homeAddress] = _sideAddress;
		TokenAdded(_homeAddress,_sideAddress);
	}

	function signMintRequest(bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint8 _v, bytes32 _r, bytes32 _s) public {
		bytes32 mintRequestsHash = sha256(_transactionHash,_mainToken,_recipient,_amount);
		//assert(isValidator(ecrecover(mintRequestsHash, _v, _r, _s)));
		if (mintRequests[mintRequestsHash] < requiredValidators){
			mintRequests[mintRequestsHash]++;
			MintRequestSigned(mintRequestsHash,_transactionHash, _mainToken,  _recipient, _amount,requiredValidators,mintRequests[mintRequestsHash]);
		}else{
			assert(mintRequestsDone[mintRequestsHash] != true);
			assert(tokenMap[_mainToken] != 0x0);
			mintRequestsDone[mintRequestsHash] = true;
			MintRequestExecuted(mintRequestsHash,_transactionHash, _mainToken,  _recipient, _amount);
			//Bridgable(tokenMap[_mainToken]).mintFromBridge(_recipient,_amount,'');
		}
	}


	// function withDrawRequest(address _token,address _recipient,uint256 _amount) public onlyOwner {
	// assert(!withdrawRequests[_id]);
	// }
}

