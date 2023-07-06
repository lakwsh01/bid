// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "./_static.sol";
import "./_base.sol";
import "../../property/property.sol";
import "../../modifier/basic.sol";

abstract contract _Auction is BasicModifier {
    constructor(
        uint256 _start_at,
        uint256 _minium_price,
        uint256 _minium_bids,
        uint256 _margin,
        uint256 _cooling_time,
        AuctionMode _mode,
        Property _property,
        address[] memory _warranter,
        address[] memory _auditor
    ) BasicModifier(_property.owner()) {
        property = _property;
        minium_price = _minium_price;
        minium_bids = _minium_bids;
        mode = _mode;
        margin = _margin;
        start_at = _start_at;
        cooling_time = _cooling_time;
        warranter = _warranter;
        auditor = _auditor;
        _status = AuctionStatus.PROCESSING;
    }

    // @non-disclosure-value :: Will not disclose until the auction is awarded.
    uint256 private minium_price;

    uint256 private minium_bids;

    // @disclosure-value :: Will disclose after the auction is awarded.
    Property public property;

    AuctionMode public mode;

    uint256 public margin;

    uint256 public start_at;

    uint256 public cooling_time;

    function cooling_off_expired_at() public view returns (uint256) {
        return start_at + cooling_time;
    }

    // Detail of Warranter
    address[] public warranter;

    function add_warranter(address _warranter) public owner_only {
        warranter.push(_warranter);
    }

    function remove_warranter(address _warranter) public owner_only {
        for (uint256 i = 0; i < warranter.length; i++) {
            if (warranter[i] == _warranter) {
                delete warranter[i];
            }
        }
    }

    // Detail of Auditor
    address[] public auditor;

    function add_auditor(address _auditor) public owner_only {
        auditor.push(_auditor);
    }

    function remove_auditor(address _auditor) public owner_only {
        for (uint256 i = 0; i < auditor.length; i++) {
            if (auditor[i] == _auditor) {
                delete auditor[i];
            }
        }
    }

    // Default Meta:
    uint256 public vaild_bids = 0;
    uint256 public total_bids = 0;
    uint256 public total_withdrawn = 0;
    uint256 public rebid = 0;

    AuctionStatus public _status;

    function status() public view returns (AuctionStatus) {
        if (
            _status == AuctionStatus.COOLING_OFFED ||
            _status == AuctionStatus.EXPIRED ||
            _status == AuctionStatus.COMPLETE ||
            _status == AuctionStatus.AWARDED ||
            _status == AuctionStatus.ABANDONMENT ||
            _status == AuctionStatus.WITHDRAWN ||
            _status == AuctionStatus.SUBSPENDED_BY_AUDITOR ||
            _status == AuctionStatus.SUBSPENDED_BY_WARRANTER ||
            _status == AuctionStatus.SUBSPENDED_BY_AUTHORITY ||
            _status == AuctionStatus.CANCELLED
        ) {
            return _status;
        } else {
            if (
                block.timestamp >= start_at &&
                block.timestamp <= start_at + cooling_time
            ) {
                return AuctionStatus.COOLING_OFF_PEROID;
            } else if (block.timestamp <= start_at) {
                return AuctionStatus.PROCESSING;
            } else {
                return AuctionStatus.ACTIVE;
            }
        }
    }

    function cooling_off() external owner_only {
        require(status() == AuctionStatus.COOLING_OFF_PEROID);
        _status = AuctionStatus.COOLING_OFFED;
    }

    function cancel() external owner_only {
        require(status() == AuctionStatus.PROCESSING);
        _status = AuctionStatus.CANCELLED;
    }

    function withdraw() external owner_only {
        AuctionStatus current_status = status();
        if (current_status == AuctionStatus.COOLING_OFF_PEROID) {
            revert(
                "The auction is in cooling off peroid, you can not withdraw now. Please try cooling_off instead."
            );
        } else {
            require(
                current_status == AuctionStatus.ACTIVE ||
                    current_status == AuctionStatus.AWARDED ||
                    current_status == AuctionStatus.COMPLETE,
                "Current status is not allowed for withdrawal."
            );
            _status = AuctionStatus.WITHDRAWN;
        }
    }

    function Complete() private {
        AuctionStatus current_status = status();

        require(
            current_status == AuctionStatus.AWARDED,
            "Only awarded Auction can be complete."
        );
        _status = AuctionStatus.COMPLETE;
    }
}
