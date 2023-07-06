// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "../ico/ico.sol";

contract Base {
    address public owner;
    address public constant ICO_ADDRESS =
        0xd2a5bC10698FD955D1Fe6cb468a17809A08fd005;

    modifier owner_only() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor(address _owner) {
        owner = _owner;
    }
}
