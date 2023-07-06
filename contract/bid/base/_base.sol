// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "./_static.sol";
import "../../auction/base/_base.sol";
import "../../tenderer/tenderer.sol";
import "../../modifier/basic.sol";

abstract contract _Bid is BasicModifier {
    uint256 public amount;
    uint256 public timestamp;
    BidStatus public status;

    constructor(
        uint256 _amount,
        _Auction _auction
    ) BasicModifier(msg.sender) {
        Tenderer tenderer = address(msg.sender); 
        require(msg.sender == address(_tenderer), "Invalid tenderer.");
        uint256 _timestamp = block.timestamp;
        require(
            _timestamp >= _auction.start_at(),
            "The bid time must be greater than the auction start time."
        );
        require(
            _timestamp <= _auction.cooling_off_expired_at(),
            "The bid time must be less than the auction cooling off time."
        );
        require(
            _auction.status() == AuctionStatus.ACTIVE,
            "Auction is not active."
        );
        uint256 _margin = _auction.margin() * _amount;
        require(_tenderer.balance() > _margin, "Insufficient balance.");

        amount = _amount;
        timestamp = _timestamp;
    }
}
