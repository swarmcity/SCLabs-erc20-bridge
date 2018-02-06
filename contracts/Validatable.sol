pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';

contract Validatable is Ownable {

	// Event created on validator gets added
	event ValidatorAdded (address validator);
	event ValidatorRemoved (address validator);
	uint8 requiredValidators = 0;

	mapping (address=>bool) public validators;

	function Validatable(uint8 _requiredValidators,address[] _initialValidators) public {
		setRequiredValidators(_requiredValidators);
        for (uint i = 0; i < _initialValidators.length; i++) {
        	addValidator(_initialValidators[i]);
        }
	}

	function addValidator(address _validator)  public onlyOwner {
		assert(validators[_validator] != true);
		validators[_validator] = true;
		ValidatorAdded(_validator);
	}

	function removeValidator(address _validator) public onlyOwner {
		validators[_validator] = false;
		ValidatorRemoved(_validator);
	}

	function setRequiredValidators(uint8 _requiredValidators) public onlyOwner {
		requiredValidators = _requiredValidators;
	}

	function isValidator(address _validator) public view returns(bool) {
		return (validators[_validator] == true);
	}

	modifier onlyValidator(address _validator) {
		assert(validators[_validator] == true);
		_;
	}	
}
