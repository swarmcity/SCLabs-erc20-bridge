pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Validatable is Ownable {

	// Event created on validator gets added
	event ValidatorAdded (address validator);
	event ValidatorRemoved (address validator);

	mapping (address=>bool) validators;

	function addValidator(address _validator)  public onlyOwner {
		assert(validators[_validator] != true);
		validators[_validator] = true;
		ValidatorAdded(_validator);
	}

	function removeValidator(address _validator) public onlyOwner {
		validators[_validator] = false;
		ValidatorRemoved(_validator);
	}

	modifier onlyValidator(address _validator) {
		assert(validators[_validator] == true);
		_;
	}	
}
