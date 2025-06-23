// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IWETH.sol";

contract Faucet is Ownable, Pausable, AccessControl, ReentrancyGuard {
  /// @notice Emits an event when `tgId` receives `amount` to `account` from faucet drop
  event FaucetDropped(uint64 tgId, address indexed account, uint amount);
  /// @notice Emits an event when `_dropAmount` changed to `newDropAmount`
  event DropAmountChanged(uint newDropAmount);
  /// @notice Emits an event when `_dropInterval` changed to `newTimeInterval`
  event DropIntervalChanged(uint newTimeInterval);
  /// @notice Emits an event when `tgId` is blocked
  event TgIdBlocked(uint64 tgId);
  /// @notice Emits an event when `tgId` is unblocked
  event TgIdUnblocked(uint64 tgId);

  /// @notice WETH token
  IWETH public immutable weth;

  /// @dev Roles that will handle all drop requests
  bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

  /// @dev Drop amount for each request
  uint private _dropAmount;
  /// @dev Drop interval for each request in seconds
  uint private _dropInterval;

  /// @dev Stores last claim timestamp of user by Telegram ID
  mapping (uint64 => uint) private _tgIds;
  /// @dev Stores last claim timestamp of user by address
  mapping (address => uint) private _accounts;
  /// @dev Stores blocked Telegram user ID
  mapping (uint64 => bool) private _blockedTgIds;

  /// @dev Faucet constructor 
  /// @param _weth WETH token address
  /// @param _drop Faucet amount for each request 
  /// @param _interval Interval for each request
  constructor(
    address _weth,
    uint _drop, 
    uint _interval
  ) Ownable(msg.sender) {
    // Grant role
    _grantRole(WITHDRAWER_ROLE, msg.sender);
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

    _dropAmount = _drop;
    _dropInterval = _interval;
    // WETH token
    weth = IWETH(_weth);
  }

  /// @notice Drop function to create multiple drop requests
  /// @dev Only callable by the `WITHDRAWER_ROLE` role
  /// @param tgIds Telegram user IDs to create multiple drop requests
  /// @param accounts Wallet addresses to create multiple drop requests
  function requests(uint64[] calldata tgIds, address[] calldata accounts) external nonReentrant whenNotPaused onlyRole(WITHDRAWER_ROLE) {
    _requests(tgIds, accounts);
  }

  /// @notice Calculate next claim time for specific user
  /// @param tgId Telegram user ID to calculate
  /// @return Next claim time in UNIX timestamp seconds format 
  function calculateNextRequest(uint64 tgId) public view virtual returns (uint) {
    return _tgIds[tgId] + _dropInterval;
  }

  /// @notice Get drop amount
  function getDropAmount() public view virtual returns (uint) {
    return _dropAmount;
  }

  /// @notice Get drop interval
  function getDropInterval() public view virtual returns (uint) {
    return _dropInterval;
  }

  /// @notice Calculate next claim time for specific wallet address
  /// @param account Wallet address to calculate
  /// @return Next claim time in UNIX timestamp seconds format 
  function calculateNextRequest(address account) public view virtual returns (uint) {
    return _accounts[account] + _dropInterval;
  }

  /// @notice Check if `tgId` can make a request
  /// @param tgId Telegram user ID to be checked
  /// @return True if current `tgId` can make a request, False otherwise
  function canRequest(uint64 tgId) public view virtual returns (bool) {
    bool isBlockedTgId = _blockedTgIds[tgId];
    uint nextAllowedRequestAt = calculateNextRequest(tgId);
    return !isBlockedTgId && block.timestamp >= nextAllowedRequestAt;
  }

  /// @notice Check if `account` can make a request
  /// @param account Wallet address to be checked
  /// @return True if current `account` can make a request, False otherwise
  function canRequest(address account) public view virtual returns (bool) {
    uint nextAllowedRequestAt = calculateNextRequest(account);
    return block.timestamp >= nextAllowedRequestAt;
  }

  /// @notice Pause the contract and stop accepting requests
  /// @dev Only callable by the contract owner
  function pause() external onlyOwner whenNotPaused {
    _pause();
  }

  /// @notice Unpause the contract and continue accepting requests
  /// @dev Only callable by the contract owner
  function unpause() external onlyOwner whenPaused {
    _unpause();
  }

  /// @notice Deposit function to top-up faucet balance 
  /// @dev Only callable by the contract owner
  function deposit() external payable onlyOwner {
    weth.deposit{value: msg.value}();
  }

  /// @notice Withdraw function to unwrap WETH from contract balance and withdraw to `recipient`
  /// @dev Only callable by the contract owner
  /// @param recipient Withdrawal recipient
  /// @param amount Withdrawal amount
  function withdraw(address recipient, uint amount) external onlyOwner {
    weth.withdraw(amount);
    (bool success, ) = recipient.call{value: amount}("");
    require(success, "Faucet: withdrawal failed");
  }

  /// @notice Recover unknown ETH from the contract balance
  /// @dev Only callable by the contract owner 
  function recover() external onlyOwner {
    uint balance = address(this).balance;
    require(balance > 0, "Faucet: no any ether in contract balance to be recovered");
    (bool success, ) = msg.sender.call{value: balance}("");
    require(success, "Faucet: ETH recover failed");
  }

  /// @notice Recover unknown `token` from the contract balance
  /// @dev Only callable by the contract owner 
  /// @param token The token address to be recovered
  function recover(address token) external onlyOwner {
    uint balanceOf = IERC20(token).balanceOf(address(this));
    IERC20(token).transfer(msg.sender, balanceOf);
  }

  /// @notice Change the amount of drop for each request
  /// @dev Only callable by the contract owner
  /// @param newDrop New drop amount 
  function changeDrop(uint newDrop) external onlyOwner {
    _dropAmount = newDrop;
    emit DropAmountChanged(newDrop);
  }

  /// @notice Change the time interval for each request
  /// @dev Only callable by the contract owner
  /// @param newInterval New interval in seconds
  function changeInterval(uint newInterval) external onlyOwner {
    _dropInterval = newInterval;
    emit DropIntervalChanged(newInterval);
  }

  /// @notice Block `tgId` and reject all requests
  /// @dev Only callable by the contract owner
  /// @param tgId Telegram user ID to be blocked
  function blockTgId(uint64 tgId) external onlyOwner {
    _updateTgIdBlockStatus(tgId, true);
  }

  /// @notice Unblock `tgId` and allow requests
  /// @dev Only callable by the contract owner
  /// @param tgId Telegram user ID to be unblocked
  function unblockTgId(uint64 tgId) external onlyOwner {
    _updateTgIdBlockStatus(tgId, false);
  }

  /// @dev Internal function to update `_tgId` block status on `_blockedTgIds`
  /// @param _tgId Telegram user ID to be blocked
  /// @param _isBlocked Block status
  function _updateTgIdBlockStatus(uint64 _tgId, bool _isBlocked) internal {
    if (_isBlocked) emit TgIdBlocked(_tgId);
    else emit TgIdUnblocked(_tgId);

    // Update block status
    _blockedTgIds[_tgId] = _isBlocked;
  }

  /// @dev Internal function to create multiple drop requests
  /// @param _userTgIds Telegram user IDs for multiple drop requests
  /// @param _userAccounts Wallet addresses for multiple drop requests
  function _requests(
    uint64[] memory _userTgIds,
    address[] memory _userAccounts
  ) internal {
    // Check whether each argument length is the same
    require(_userTgIds.length == _userAccounts.length, "Faucet: mismatched length of _tgIds and _accounts argument");

    // Calculate total amount of WETH to create a multiple drop request
    uint requiredAmount;
    uint balanceOf = weth.balanceOf(address(this));
    for (uint i = 0; i < _userTgIds.length; i++) {
      requiredAmount += _dropAmount;
    }

    require(balanceOf >= requiredAmount, "Faucet: insufficient WETH balance to create multiple requests");

    // Withdraw WETH and perform multiple drop requests
    weth.withdraw(requiredAmount);

    for (uint i = 0; i < _userAccounts.length; i++) {
      uint64 tgId = _userTgIds[i];
      address account = _userAccounts[i];

      // No need to revert, just check and skip if criteria doesn't met
      if (canRequest(tgId) && canRequest(account)) {
        (bool success, ) = account.call{value: _dropAmount}("");
        // Revert only when drop failed
        require(success, "Faucet: drop failed");

        // Update states only if drop is successful
        _tgIds[tgId] = block.timestamp;
        _accounts[account] = block.timestamp;
        emit FaucetDropped(tgId, account, _dropAmount);
      }
    }
  }
}