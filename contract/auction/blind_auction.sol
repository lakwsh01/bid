// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "./base/_base.sol";
import "./base/_static.sol";
import "../bid/blind_bid.sol";

contract BlindAuction is _Auction {
    constructor(
        uint256 _start_at,
        uint256 _minium_price,
        uint256 _minium_bids,
        uint256 _margin,
        uint256 _cooling_off,
        AuctionMode _mode,
        Property _property,
        address[] memory _warranter,
        address[] memory _auditor
    )
        _Auction(
            _start_at,
            _minium_price,
            _minium_bids,
            _margin,
            _cooling_off,
            _mode,
            _property,
            _warranter,
            _auditor
        )
    {}

    // @non-disclosure-value :: Will not disclose until the auction is awarded.
    mapping(address => uint256) private eth_balances;

    // @disclosure-value :: Will disclose after the auction is awarded.
    mapping(address => uint256) public bids;

    mapping(address => BlindBidStatus) public status;




    function bid() public payable {
        require(msg.value >= minium_bids);
        require(block.timestamp >= start_at);
        require(block.timestamp <= start_at + cooling_off);
        require(status[msg.sender] == BlindBidStatus.ACTIVE);
        eth_balances[msg.sender] += msg.value;
        bids[msg.sender] += msg.value;
    }

    function withdraw() public {
        require(status[msg.sender] == BlindBidStatus.ACTIVE);
        status[msg.sender] = BlindBidStatus.WITHDRAWN;
        payable(msg.sender).transfer(eth_balances[msg.sender]);
    }

    function reject(address _bidder) public {
        require(msg.sender == property.owner());
        require(status[_bidder] == BlindBidStatus.ACTIVE);
        status[_bidder] = BlindBidStatus.REJECTED;
        payable(_bidder).transfer(eth_balances[_bidder]);
    }

    function award(address _bidder) public {
        require(msg.sender == property.owner());
        require(status[_bidder] == BlindBidStatus.ACTIVE);
        require(bids[_bidder] >= minium_price);
        status[_bidder] = BlindBidStatus.REJECTED;
        payable(property.owner()).transfer(bids[_bidder]);
        payable(_bidder).transfer(eth_balances[_bidder] - bids[_bidder]);
    }
}
