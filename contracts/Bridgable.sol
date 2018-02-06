pragma solidity ^0.4.18;

contract Bridgable {

	address public bridgeAddress;

	function mintFromBridge(address _to,uint256 _amount, bytes _operatorData) public;

	function Bridgable(address _bridgeAddress){
		bridgeAddress = _bridgeAddress;
	}


	modifier onlyBridge(){
		assert(msg.sender == bridgeAddress);
		_;
	}
}
