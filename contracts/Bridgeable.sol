pragma solidity ^0.4.18;

contract Bridgeable {

	address public bridgeAddress;

	function mintFromBridge(address _to,uint256 _amount,bytes _operatorData) public;

	function Bridgeable(address _bridgeAddress) public {
		bridgeAddress = _bridgeAddress;
	}

	modifier onlyBridge(){
		assert(msg.sender == bridgeAddress);
		_;
	}
}
