pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import './Validatable.sol';

contract HomeERC20Bridge is Validatable {

	mapping(bytes32=>bool) usedHashes;
	
	event BridgeETH(address from, uint256 value);

	function HomeERC20Bridge(uint8 _requiredValidators,address[] _initialValidators) Validatable(_requiredValidators,_initialValidators) public {

	}

	// ETH deposit
	function() payable {
		BridgeETH(msg.sender,msg.value);
	}

	function withdraw(address _token, address _recepient,uint _amount,uint _withdrawblock,uint8[] _v, bytes32[] _r, bytes32[] _s) public{

		bytes32 hash = sha256(_token,_recepient,_amount,_withdrawblock);

		// the hash should not have been used before
		assert(usedHashes[hash] == false);

		// the time-lock should have passed
        assert(_withdrawblock >= block.number);		

		// verify the provided signatures
		uint8 approvals = 0;
        for (uint i = 0; i < _v.length; i++) {
        	assert(validators[ecrecover(hash, _v[i], _r[i], _s[i])] == true);
        	approvals++;
        }

		// verify if the threshold of valid signatures is met
        assert(approvals >= requiredValidators);

		// all OK. mark hash as used & Transfer tokens
		usedHashes[hash] = true;
		assert(ERC20Basic(_token).transfer(_recepient,_amount));
		
	}	

}

