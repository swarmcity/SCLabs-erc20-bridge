pragma solidity ^0.4.18;

import 'eip777/contracts/ReferenceToken.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract ForeignERC777Bridge is Ownable {

	//track used fillup hashes
	mapping(bytes32=>bool) withdrawRequests;

	// maps home token addresses -> foreign token addresses
	mapping(address=>address) tokenMap;

	function registerToken(address _homeAddress,string _name, string _symbol) public onlyOwner {
		assert(tokenMap[_homeAddress] == 0);
		// create the new token
		//address t = new ReferenceToken(_name,_symbol,1);
		address t = new ReferenceToken('Reference Token','XRT',100000000000000);
		tokenMap[_homeAddress] = t;
	}

	function mintTokens(address _token, address _recepient,uint256 _amount) public onlyOwner {
		assert(tokenMap[_token] != 0);
		ReferenceToken(tokenMap[_token]).mint(_recepient,_amount,"");
	}

	// function withDrawRequest(address _from, address _token,address _recepient,uint256 _amount) public onlyOwner {
	// 	//assert(!withdrawRequests[_id]);
	// }
}

