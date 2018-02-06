pragma solidity ^0.4.18;

import 'eip777/contracts/ITokenRecipient.sol';
import 'eip777/contracts/ReferenceToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validatable.sol';

interface IBridgable {
	function mintFromBridge(address _to,uint256 _amount) public;
}

contract ForeignERC777Bridge is Ownable, Validatable {

	mapping(bytes32=>uint8) mintRequests;
	mapping(bytes32=>bool) mintRequestsDone;

	mapping(bytes32=>uint8) withdrawRequests;
	mapping(address=>bool) validators;

	// maps home token addresses -> foreign token addresses
	mapping(address=>address) tokenMap;

	event WithdrawRequest(address _to,uint256 _amount,bytes32 _withdrawhash);
	event TokenAdded(address _homeAddress,address _sideAddress);

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

	function signMintRequest(bytes32 _transactionHash,address _mainToken, address _recipient,uint256 _amount,uint8 _v, bytes32 _r, bytes32 _s) public onlyOwner{
		bytes32 mintRequestsHash = sha256(_transactionHash,_mainToken,_recipient,_amount);
		assert(isValidator(ecrecover(mintRequestsHash, _v, _r, _s)));
		if (mintRequests[mintRequestsHash] < requiredValidators){
			mintRequests[mintRequestsHash]++;
		}else{
			IBridgable(tokenMap[_mainToken]).mintFromBridge(_recipient,_amount);
			mintRequestsDone[mintRequestsHash] = true;
		}
	}

	// function mintTokens(address _token, address _recipient,uint256 _amount) public onlyOwner {
	// 	assert(tokenMap[_token] != 0);
	// 	ReferenceToken(tokenMap[_token]).mint(_recipient,_amount,"");
	// }

	// the ERC777 token will call this function when a token is sent to the bridge.
	// function tokensReceived(
	//     address from,
	//     address to,
	//     uint amount,
	//     bytes userData,
	//     address operator,
	//     bytes operatorData
	// ) public{
	// 	bytes32 hash = sha256(from,amount,userData);
	// 	// notify validators of this request.
	// 	WithdrawRequest(from,amount,hash);
	// }


	// function withDrawRequest(address _token,address _recipient,uint256 _amount) public onlyOwner {
	// assert(!withdrawRequests[_id]);
	// }
}

