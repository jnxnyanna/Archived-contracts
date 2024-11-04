// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract DynamicFaucet {
  address public owner;
  uint256 public dropRate = 0.000005 ether;
  bool public isPaused = false;
  uint256 public dropPeriod = 1 days;

  mapping(address => bool) private admins;
  mapping(address => bool) private blocklist;
  mapping(address => uint256) public lastClaim;

  event PauseFaucet(address indexed _by, bool _state);
  event RequestFunds(address indexed _dst, address indexed _for, uint256 _wei);
  event OwnershipTransferred(address indexed _old, address indexed _new);

  constructor() {
    owner = msg.sender;
    admins[owner] = true;
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Faucet: Caller is not owner");
    _;
  }

  modifier onlyAdmins() {
    require(admins[msg.sender], "Faucet: Caller is not admin");
    _;
  }

  receive() external payable {}

  function transferOwnership(address _newOwner) public onlyOwner {
    require(_newOwner != address(0), "Faucet: New owner is the zero address");
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
    if (!admins[_newOwner]) {
      admins[_newOwner] = true; 
    }
  }

  function changeDropRate(uint256 _drop) external onlyAdmins {
    dropRate = _drop;
  }

  function changeDropPeriod(uint256 _period) external onlyAdmins {
    dropPeriod = _period;
  }

  function pause() external onlyAdmins {
    require(!isPaused, "Faucet: Already paused");
    emit PauseFaucet(msg.sender, true);
    isPaused = true;
  }

  function unpause() external onlyAdmins {
    require(isPaused, "Faucet: Already unpaused");
    emit PauseFaucet(msg.sender, false);
    isPaused = false;
  }

  function nextRequest(address _dst) public view returns (uint256) {
    if (block.timestamp >= lastClaim[_dst] + dropPeriod) {
      return 0;
    }
    return lastClaim[_dst] + dropPeriod;
  }

  function canRequestFunds(address _dst) public view returns (bool) {
    return block.timestamp >= nextRequest(_dst);
  }

  function isBlocked(address _dst) public view returns (bool) {
    return blocklist[_dst];
  }

  function setBlocklist(address _dst, bool _state) external onlyAdmins {
    blocklist[_dst] = _state;
  }

  function addAdmin(address _admin) external onlyOwner {
    admins[_admin] = true;
  }

  function removeAdmin(address _admin) external onlyOwner {
    require(_admin != msg.sender, "Faucet: Owner cannot remove themselves as admin");
    admins[_admin] = false;
  }
  
  function requestFunds(address _recipient) external {
    require(!isPaused, "Faucet: Faucet is paused");
    require(!blocklist[msg.sender], "Faucet: Caller is blacklisted");
    require(!blocklist[_recipient], "Faucet: Recipient is blacklisted");
    require(canRequestFunds(_recipient), "Faucet: Recipient already requested funds within cooldown period");
    require(address(this).balance >= dropRate, "Faucet: Insufficient balance");
   
    payable(_recipient).transfer(dropRate);
    lastClaim[_recipient] = block.timestamp;
    emit RequestFunds(msg.sender, _recipient, dropRate);
  }
}
