pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

import './Validatable.sol';

contract HomeERC20Bridge is Validatable {
	using SafeMath for uint256;

	mapping(bytes32=>bool) usedHashes;
	
	event BridgeETH(address from, uint256 value);

	function HomeERC20Bridge(uint8 _requiredValidators,address[] _initialValidators) Validatable(_requiredValidators,_initialValidators) public {

	}

	// ETH deposit
	function() public payable {
		BridgeETH(msg.sender,msg.value);
	}

	event EmitHash(bytes32 _hash);

	function checkValidations(
		bytes32 _hash,
		uint256 _length,
		uint8[] _v,
		bytes32[] _r,
		bytes32[] _s) public view returns(uint8){
		uint8 approvals = 0;
        for (uint i = 0; i < _length ; i++) {
        	address validator = ecrecover(_hash, _v[i], _r[i], _s[i]);
        	assert(isValidator(validator));
        	approvals++;
        }
        return approvals;
	}

	function withdraw(
		address _token,
		address _recipient,
		uint256 _amount,
		uint256 _withdrawblock,
		uint256 _reward,
		uint8[] _v,
		bytes32[] _r,
		bytes32[] _s) public{

		bytes32 hash = sha256(_token,_recipient,_amount,_withdrawblock);

		// the hash should not have been used before
		assert(usedHashes[hash] == false);

		// mark hash as used
		usedHashes[hash] = true;

		// the time-lock should have passed
        assert(_withdrawblock <= block.number);		

		// verify the provided signatures
		assert(_v.length > 0);

        if (_reward > 0) {
	        assert(_reward < _amount);
			// verify if the threshold of required signatures is met
    	    assert(checkValidations(hash,_v.length-1,_v,_r,_s) >= requiredValidators);
		    // check if the reward has been signed off by the receiver ( last signature ) ...
    		bytes32 rewardHash = sha256(_token,_recipient,_amount,_withdrawblock,_reward);
    		assert(ecrecover(rewardHash, _v[_v.length-1], _r[_v.length-1], _s[_v.length-1]) == _recipient);
			// all OK. mark hash as used & Transfer tokens + reward
			if (_token == 0x0){
				// ETH transfer
				_recipient.transfer(_amount.sub(_reward));
				msg.sender.transfer(_reward);
			}else{
				// ERC-20 transfer
				assert(ERC20Basic(_token).transfer(_recipient,_amount.sub(_reward)));
				assert(ERC20Basic(_token).transfer(msg.sender,_reward));
			}		
        }else{
			// verify if the threshold of required signatures is met
    	    assert(checkValidations(hash,_v.length,_v,_r,_s) >= requiredValidators);
			if (_token == 0x0){
				// ETH transfer
				_recipient.transfer(_amount);
			}else{
				// ERC-20 transfer
				assert(ERC20Basic(_token).transfer(_recipient,_amount));
			}
        }
	}	


}

