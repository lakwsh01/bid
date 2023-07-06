// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.19;

// Equity check

contract ICO {
    uint public total_supply = 1000000000000000000000000000; // 1 billion tokens
    uint public rate = 1000; // 1 USD = 1000 tokens
    uint public min_purchase = 1; // 0.1 ETH

    // Current Token supply
    uint public current_supply = 0;

    // Equity check
    mapping(address => uint) public eth_balances;

    function buy() public payable {
        require(msg.value >= min_purchase);
        uint tokens = msg.value * rate;
        require(current_supply + tokens <= total_supply);
        eth_balances[msg.sender] += tokens;
        current_supply += tokens;
    }

    function sell() public payable {
        require(eth_balances[msg.sender] > msg.value);
        eth_balances[msg.sender] -= msg.value;
        current_supply += msg.value;
    }
}
