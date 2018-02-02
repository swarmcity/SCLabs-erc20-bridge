pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract HomeERC20Bridge is Ownable {

	// Event created on validator gets added
	event ValidatorAdded (address validator);
	event ValidatorRemoved (address validator);

	mapping (address=>bool) validators;

	function withdraw(address _token, address _recepient,uint _amount,bytes32 _withdrawhash, uint8[] _validators,uint8[] v, bytes32[] r, bytes32[] s) public{
		// iterate over validators
		// check if signature 
		assert(ERC20Basic(_token).transfer(_recepient,_amount));
	}

	function addValidator(address _validator) public onlyOwner {
		assert(validators[_validator] != true);
		validators[_validator] = true;
		ValidatorAdded(_validator);
	}

	function removeValidator(address _validator) public onlyOwner{
		validators[_validator] = false;
		ValidatorRemoved(_validator);
	}
}

