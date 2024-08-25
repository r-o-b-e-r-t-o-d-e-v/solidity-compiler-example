// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract DummyContract {
    uint256 private value;

    event ValueChange(address changer, uint256 value);

    constructor() {
        value = 17;
    }

    function setValue(uint256 _value) external {
        require(value != _value, "Current value matches the new one");
        value = _value;
        emit ValueChange(msg.sender, _value);
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}
