pragma solidity ^0.4.18;

import 'eip777/contracts/ReferenceToken.sol';
import './Bridgable.sol';

contract SidechainToken is ReferenceToken,Bridgable {
	function SidechainToken(address _bridgeAddress) Bridgable(_bridgeAddress) public {}

	function mintFromBridge(address _recepient,uint256 _amount, bytes _operatorData) public onlyBridge {
		mint(_recepient,_amount, _operatorData);
	}
}
