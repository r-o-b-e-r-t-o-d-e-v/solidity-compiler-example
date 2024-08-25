// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract SimpleToken {
    mapping(address => uint256) private balances;

    event Transfer(address _sender, address _receiver, uint256 _value);

    error NotEnoughBalances(address _sender, uint256 _value);

    constructor() {
        balances[msg.sender] = 1_000_000;
    }

    modifier hasEnoughFunds(address _address, uint256 amount) {
        if (balances[_address] < amount) {
            revert NotEnoughBalances(_address, amount);
        }
        _;
    }

    function name() external pure returns (string memory) {
        return "Simple Token";
    }

    function symbol() external pure returns (string memory) {
        return "SIMPLE";
    }

    function decimals() external pure returns (uint8) {
        return 0;
    }

    function totalSupply() external pure returns (uint256) {
        return 1_000_000;
    }

    function transfer(address _receiver, uint256 _amount) external hasEnoughFunds(msg.sender, _amount) {
        balances[msg.sender] -= _amount;
        balances[_receiver] += _amount;
        emit Transfer(msg.sender, _receiver, _amount);
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return balances[_owner];
    }
}
