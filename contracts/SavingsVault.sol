// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract SavingsVault {
    address public owner;
    uint256 public vault;
    uint32 public constant SECONDS_IN_DAYS = 86400;
    uint16 public constant MINIMUM_WITHDRAW_PERIOD = 3;
    uint16 public constant MAXIMUM_WITHDRAW_PERIOD = 1095;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public balances;
    mapping(address => uint256) public lastWithdrawal;
    mapping(address => uint16) public withdrawPeriod;

    constructor() {
        owner = msg.sender;
    }

    event Deposit(uint256 value);
    event Withdraw(address destination, uint256 value);

    modifier onlyWhitelisted() {
        require(whitelisted[msg.sender], "Account is not whitelisted.");
        _;
    }

    modifier needValidPeriod(uint16 period) {
        require(period >=
            MINIMUM_WITHDRAW_PERIOD && period <= MAXIMUM_WITHDRAW_PERIOD,
            "Withdrawal period must be between 3 and 1095 days."
        );
        _;
    }

    modifier canWithdraw() {
        require(block.timestamp >=
            lastWithdrawal[msg.sender] + (withdrawPeriod[msg.sender] * SECONDS_IN_DAYS) ||
            lastWithdrawal[msg.sender] == 0,
            "Account is in withdraw cooldown period."
        );
        _;
    }

    function _changeOwner(address newOwner) external {
        require(msg.sender == owner, "Account is not owner.");
        owner = newOwner;
    }

    function deposit() external payable onlyWhitelisted {
        balances[msg.sender] += msg.value;
        vault += msg.value;
        emit Deposit(msg.value);
    }

    function withdraw(address payable destination, uint256 value) external onlyWhitelisted canWithdraw {
        require(balances[msg.sender] >= value, "Insufficient balance on vault.");
        balances[msg.sender] -= value;
        lastWithdrawal[msg.sender] = block.timestamp;
        vault -= value;
        destination.transfer(value);
        emit Withdraw(destination, value);
    }

    function whitelist(uint16 period) external needValidPeriod(period) {
        whitelisted[msg.sender] = true;
        withdrawPeriod[msg.sender] = period;
    }

    function unwhitelist() external onlyWhitelisted {
        require(balances[msg.sender] == 0, "Account has balance on vault.");
        whitelisted[msg.sender] = false;
        withdrawPeriod[msg.sender] = 0;
    }

    function changeWithdrawPeriod(uint16 newPeriod) external onlyWhitelisted needValidPeriod(newPeriod) {
        withdrawPeriod[msg.sender] = newPeriod;
    }

    function withdrawUnknownFunds(address payable _to) external {
        require(msg.sender == owner, "Account is not owner.");
        uint256 unknownFunds = address(this).balance - vault;
        _to.transfer(unknownFunds);
    }

    function isWithdrawTime(address user) external view returns (bool) {
        return block.timestamp >= lastWithdrawal[user] + (withdrawPeriod[user] * SECONDS_IN_DAYS);
    }

    function nextWithdrawTime(address user) external view returns (uint256) {
        uint256 nextTime = lastWithdrawal[user] + (withdrawPeriod[user] * SECONDS_IN_DAYS);
        if (block.timestamp >= nextTime) return 0;
        return nextTime - block.timestamp;
    }

    receive() external payable {
        revert("Direct deposit are not allowed. Please use deposit function.");
    }
}
