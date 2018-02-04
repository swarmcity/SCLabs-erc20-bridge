pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validatable.sol';

contract HomeERC20Bridge is Validatable {

	function withdraw(address _token, address _recepient,uint _amount,bytes32 _withdrawhash, uint8[] _validators,uint8[] v, bytes32[] r, bytes32[] s) public{
		// iterate over validators
		// check if signature 
		assert(ERC20Basic(_token).transfer(_recepient,_amount));
	}

}

