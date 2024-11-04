// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Donation {
    address public owner;
    uint256 public donationsTimes;
    uint256 public donationsValue;

    uint256 private MINIMUM_WITHDRAWAL = 0.01 * (10 ** 18);

    event Donations(address indexed sender, uint256 value);
    event Withdraw(address indexed recipient, uint256 value);
    event OwnershipTransferred(address indexed oldOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _to) external onlyOwner {
        require(_to != address(0), "New owner cannot be zero address");
        emit OwnershipTransferred(owner, _to);
        owner = _to;
    }

    function withdraw(address _to, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount cannot be zero");
        require(address(this).balance >= _amount, "Insufficient contract balance");
        payable(_to).transfer(_amount);
        emit Withdraw(_to, _amount);
    }

    receive() external payable {
        donationsTimes += 1;
        donationsValue += msg.value;
        emit Donations(msg.sender, msg.value);

        if (address(this).balance >= MINIMUM_WITHDRAWAL) {
            withdraw(owner, address(this).balance);
        }
    }
}