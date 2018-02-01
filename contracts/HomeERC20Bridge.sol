pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';

contract HomeERC20Bridge {

	// Event created on validator gets added deposit.
	event ValidatorAdded (address validator);

	//address[] _validators;

	// function HomeERC20Bridge(address[] _validators){
	// 	validators = _validators;
	// }

	function withdraw(address _token, address _recepient,uint _amount) public{
		assert(ERC20Basic(_token).transfer(_recepient,_amount));
	}
}

