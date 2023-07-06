// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

import "./base/_static.sol";
import "../base/base.sol";

contract Property is Base {
    PropertyType public property_type; // Type of the property
    uint8 public latitude; // Latitude of the property
    uint8 public longitude; // Longitude of the property

    string public country; // Country of the property
    string public region; // Region of the property
    string public city; // City of the property
    string public street; // Street of the property
    string public street_number; // Street number of the property
    string public floor; // Floor of the property
    string public flat; // Door of the property
    string public zip_code; // Zip code of the property

    constructor(
        uint8 _latitude,
        uint8 _longitude,
        uint8 _property_type,
        address _owner,
        string memory _country,
        string memory _region,
        string memory _city,
        string memory _street,
        string memory _street_number,
        string memory _zip_code
    ) BasicModifier(_owner) {
        latitude = _latitude;
        longitude = _longitude;
        country = _country;
        region = _region;
        city = _city;
        street = _street;
        street_number = _street_number;
        zip_code = _zip_code;
        property_type = _property_type;
    }
}
