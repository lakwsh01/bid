// SPDX-License-Identifier: MIT
pragma solidity >0.7.0 <0.9.0;

contract Asset {
    // 1 Billion ETH
    uint256 public constant MAX_TOKEN = 1000000000 ether;
    uint256 public minium_buying_unit = 1 wei;
    uint256 public minium_selling_unit = 1 wei;
    uint256 public rate = 100000; // rate in usd ::: 100000 USD = 1 ETH
    uint256 public token_released = 0; // token released

    mapping(address => uint256) private _balance;
    mapping(address => uint256) private _reserved;
    mapping(address => address[]) private _properties;
    mapping(address => address[]) private _auctions;
    mapping(address => _Profile) private profile;

    struct _Profile {
        string custom_id;
        string user_name;
        uint256 withdrawn_count;
        uint256 abandoned_count;
        uint256 complete_count;
        uint256 latest_login;
        uint256 create_at;
    }

    // Create profile
    event ProfileCreated(
        address indexed from,
        string custom_id,
        string user_name,
        uint256 create_at
    );

    function create_profile(
        string memory custom_id,
        string memory user_name
    ) public returns (bool) {
        require(profile[msg.sender].create_at == 0, "Profile already created");
        uint256 timestamp = block.timestamp;
        profile[msg.sender] = _Profile(
            custom_id,
            user_name,
            0,
            0,
            0,
            timestamp,
            timestamp
        );
        emit ProfileCreated(msg.sender, custom_id, user_name, timestamp);
        return true;
    }

    // Update profile
    event ProfileUpdated(
        address indexed from,
        string custom_id,
        string user_name,
        uint256 update_at
    );

    function update_profile(
        string memory _user_name,
        string memory _custom_id
    ) external returns (bool) {
        require(profile[msg.sender].create_at != 0, "Profile not Exist");
        profile[msg.sender].user_name = _user_name;
        profile[msg.sender].custom_id = _custom_id;
        emit ProfileUpdated(
            msg.sender,
            _custom_id,
            _user_name,
            block.timestamp
        );
        return true;
    }

    function properties(
        address account
    ) public view returns (address[] memory) {
        return _properties[account];
    }

    function auctions(address account) public view returns (address[] memory) {
        return _auctions[account];
    }

    function balance() public view returns (uint256) {
        return _balance[msg.sender];
    }

    // Buy token
    event TokenBought(address indexed from, uint256 value);

    function buy(uint256 usd) public returns (uint256) {
        uint256 token = usd / rate;
        token_released += token;
        _balance[msg.sender] += token;

        emit TokenBought(msg.sender, token);
        return _balance[msg.sender];
    }

    // Sell token
    event TokenSold(address indexed from, uint256 token, uint256 usd);

    function sell() public payable returns (uint256) {
        token_released -= msg.value;
        _balance[msg.sender] -= msg.value;
        emit TokenSold(msg.sender, msg.value, msg.value * rate);
        return _balance[msg.sender];
    }

    // Reserve deposit
    event ReservedDeposit(address indexed from, uint256 value);

    function deposit(uint256 value) internal returns (uint256) {
        _reserved[msg.sender] += value;
        emit ReservedDeposit(msg.sender, value);
        return _reserved[msg.sender];
    }

    // Refund deposit
    event RefundDeposit(address indexed to, uint256 value);

    function refund_deposit(uint256 value) internal returns (uint256, uint256) {
        _reserved[msg.sender] -= value;
        _balance[msg.sender] += value;
        emit RefundDeposit(msg.sender, value);
        return (_reserved[msg.sender], _balance[msg.sender]);
    }

    // Transfer ETH
    event Transfer(address indexed from, address indexed to, uint256 value);

    function transfer(address to) external payable returns (bool) {
        _balance[msg.sender] -= msg.value;
        _balance[to] += msg.value;
        emit Transfer(msg.sender, to, msg.value);
        return true;
    }
}
