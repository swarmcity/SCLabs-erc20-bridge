pragma solidity ^0.4.18;

import 'eip777/contracts/ReferenceToken.sol';
import 'eip777/contracts/ITokenRecipient.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ForeignERC777Bridge is Ownable, ITokenRecipient {

	//track used fillup hashes
	mapping(bytes32=>bool) withdrawRequests;

	// maps home token addresses -> foreign token addresses
	mapping(address=>address) tokenMap;

	event WithdrawRequest(address _to,uint256 _amount,bytes32 _withdrawhash);

	function registerToken(address _homeAddress,string _name, string _symbol) public onlyOwner {
		assert(tokenMap[_homeAddress] == 0);
		// create the new token
		address t = new ReferenceToken(_name,_symbol,1);
		tokenMap[_homeAddress] = t;
	}

	function mintTokens(address _token, address _recipient,uint256 _amount) public onlyOwner {
		assert(tokenMap[_token] != 0);
		ReferenceToken(tokenMap[_token]).mint(_recipient,_amount,"");
	}

	// the ERC777 token will call this function when a token is sent to the bridge.
	function tokensReceived(
	    address from,
	    address to,
	    uint amount,
	    bytes userData,
	    address operator,
	    bytes operatorData
	) public{
		bytes32 hash = sha256(from,amount,userData);
		// notify validators of this request.
		WithdrawRequest(from,amount,hash);
	}


	// function withDrawRequest(address _token,address _recipient,uint256 _amount) public onlyOwner {
	// assert(!withdrawRequests[_id]);
	// }
}

