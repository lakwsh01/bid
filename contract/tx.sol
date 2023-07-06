// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

contract Tenderer {
    // function bid(Auction auction) public payable {
    //     auction._bid{value: msg.value}();
    // }
    // function withdraw() public {}
    // function cooling_off(Auction auction) public {
    //     require(auction.tenderer() == msg.sender);
    //     require(auction.is_waiting_for_cooling_off());
    // }

    mapping(address => uint) public balance;
    mapping(address => string) public tenderer_name;

    function blind_bid(Auction auction, uint256 amount) public {
        require(auction.margin() <= balance[msg.sender]);
    }
}

contract BlindBid {
    uint256 public amount;
    uint256 public timestamp;
    BlindBidStatus public biding_mode;
    Auction private auction;
    Tenderer private tenderer;

    constructor(Auction _auction, uint256 _amount, address _tenderer) {
        amount = _amount;
        tenderer = _tenderer;
        timestamp = block.timestamp;
        auction = _auction;
        biding_mode = BlindBidStatus.ACTIVE;
    }

    function bid(uint256 _amount, Tenderer _tenderer) internal {
        require();
        require(biding_mode == BlindBidStatus.ACTIVE);
        require(msg.value > bid);
        bid = msg.value;
        timestamp = block.timestamp;
    }

    function withdraw() public {}
}


abstract contract Auction {
    // A static number will reserve as margin for equity owner and warranter.
    // The margin must higher than 2.5% of minium price, set by equity owner or default.
    // Owner, Warranter, Tenderer have to pay margin if they want to join the auction.
    // The margin will be returned after the deal complete.
    // The margin will be returned if the deal failed under certain conditions.
    // 1. The auction has no tenderer.
    // 2. The highest bid is lower than the minium price.
    // 3. The warranter or the owner cancel the auction before cooling off period expired.
    // 4. The bit count under the minium bids.

    // Percentage of minium price / Percentage of bid
    uint256 public margin;
    Auction public mode;

    // Current status of the auction
    // @disclosure-value

    uint256 _current_price;
    uint256 _current_bid_timestamp;
    address _current_tenderer;

    // Meta of the auction
    // @non-disclosure-value :: Will not disclose until the auction is awarded.
    uint256 private _minium_price;
    uint256 private _minium_bids;

    // @disclosure-value
    uint256 public vaild_bids = 0;
    uint256 public per_bid;
    uint256 public start_at;
    uint256 public cooling;

    function is_vaild_at() public view returns (uint256) {
        return _current_bid_timestamp + cooling;
    }

    function is_waiting_for_cooling() public view returns (bool) {
        return block.timestamp < (_current_bid_timestamp + cooling);
    }

    // Interval is a time period that the auction will be extended if there is a new bid.
    // The interval will be set by the owner or default at 24 Hours.
    // The interval will be reset if there is a new bid.
    // The auction will go into racing state if bids count greater than minium bids.
    // The racing_interval will be set by the owner or default interval/10.
    // The auction will end if there is no new bid after racing_interval.
    // The auction will be awarded to the highest bidder if _current_price > _minium_price.
    // EG: interval = 24 hours, racing_interval = 2 hours and 24 minutes.
    uint256 private interval;
    uint256 private racing_interval;

    // function racing_interval() public view returns (uint256) {
    //     // bids_interval = (Interval * (minium_bids - bits_count)) + cooling + _minium_racing_time_addon
    //     uint256 bid_difference = _minium_bids - vaild_bids;
    //     if (bid_difference > 0) {
    //         return interval * (_minium_bids - vaild_bids);
    //     } else {
    //         return interval * (_minium_bids - vaild_bids);
    //     }
    // }

    // Detail Of Owner
    address public equity_owner;

    // Detail of Warranter
    address public warranter;

    // Detail of Auditor
    address public auditor;

    // constructor(
    //     uint256 minium,
    //     uint256 award,
    //     uint256 per_bid,
    //     uint256 margin,
    //     uint256 cooling,
    //     uint256 racing_interval,
    //     uint256 biding_mode
    // ) {
    //     require(cooling < racing_interval && 3600<cooling );
    //     _minium = minium;
    //     _award = award;
    //     _per_bid = per_bid;
    //     _margin = margin;
    //     _cooling = cooling;
    //     _start_at = block.timestamp;
    //     _owner = msg.sender;
    //     _current_price = minium;
    //     _racing_interval = racing_interval;
    //     _biding_mode = biding_mode;
    // }

    // function _bid() internal payable {
    //     require(msg.value >= _minium);
    //     require(msg.value >= _current_price + _per_bid);

    //     _current_price = msg.value;
    //     _current_bid_timestamp = block.timestamp;
    //     _current_tenderer = msg.sender;
    // }

    // function is_waiting_for_cooling_off() public view returns (bool) {
    //     return block.timestamp < (_current_bid_timestamp + _cooling);
    // }

    // function tenderer() public view returns (address) {
    //     return _current_tenderer;
    // }
}
