pragma solidity ^0.4.18;

import 'eip777/contracts/ReferenceToken.sol';
import './Bridgeable.sol';

contract SidechainToken is ReferenceToken,Bridgeable {

	function SidechainToken(
		address _bridgeAddress,
		string _name,
        string _symbol,
        uint256 _granularity
    ) Bridgeable(_bridgeAddress) ReferenceToken(_name,_symbol,_granularity)
    	public
    {}

	function mintFromBridge(address _recepient,uint256 _amount, bytes _operatorData) public onlyBridge {
		mint(_recepient,_amount, _operatorData);
	}
}
