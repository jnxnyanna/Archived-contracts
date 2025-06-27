// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "./IWETH.sol";

/// @title Faucet Contract for Distributing WETH
/// @notice This contract allows authorized users to distribute WETH to users based on Telegram IDs and wallet addresses, with configurable drop amounts and intervals
/// @dev Inherits from OpenZeppelin's Ownable, Pausable, AccessControl, and ReentrancyGuard for secure and controlled access
contract Faucet is Ownable, Pausable, AccessControl, ReentrancyGuard {
    /// @notice Emitted when a user with `tgId` receives `amount` WETH to `account` from a faucet drop
    /// @param tgId The Telegram user ID of the recipient
    /// @param account The wallet address receiving the WETH
    /// @param amount The amount of WETH dropped
    event FaucetDropped(uint64 indexed tgId, address indexed account, uint256 amount);

    /// @notice Emitted when the drop amount is changed to `newDropAmount`
    /// @param newDropAmount The new drop amount for each request
    event DropAmountChanged(uint256 newDropAmount);

    /// @notice Emitted when the drop interval is changed to `newTimeInterval`
    /// @param newTimeInterval The new interval (in seconds) between requests
    event DropIntervalChanged(uint256 newTimeInterval);

    /// @notice Emitted when a Telegram user ID `tgId` is blocked
    /// @param tgId The Telegram user ID that was blocked
    event TgIdBlocked(uint64 indexed tgId);

    /// @notice Emitted when a Telegram user ID `tgId` is unblocked
    /// @param tgId The Telegram user ID that was unblocked
    event TgIdUnblocked(uint64 indexed tgId);

    /// @notice The WETH token contract used for faucet distributions
    IWETH public immutable weth;

    /// @notice Role identifier for users authorized to handle drop requests
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");

    /// @dev The amount of WETH distributed per drop request
    uint256 private _dropAmount;

    /// @dev The time interval (in seconds) between allowed drop requests for a user
    uint256 private _dropInterval;

    /// @dev Mapping of Telegram user IDs to their last claim timestamp
    mapping(uint64 => uint256) private _tgIds;

    /// @dev Mapping of wallet addresses to their last claim timestamp
    mapping(address => uint256) private _accounts;

    /// @dev Mapping of Telegram user IDs to their block status
    mapping(uint64 => bool) private _blockedTgIds;

    /// @notice Constructor to initialize the faucet contract
    /// @dev Sets the contract owner, grants roles, and initializes WETH address, drop amount, and interval
    /// @param _weth The address of the WETH token contract
    /// @param _drop The amount of WETH to distribute per request
    /// @param _interval The time interval (in seconds) between allowed requests
    constructor(address _weth, uint256 _drop, uint256 _interval) Ownable(msg.sender) {
        // Grant WITHDRAWER_ROLE and DEFAULT_ADMIN_ROLE to the contract deployer
        _grantRole(WITHDRAWER_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        // Initialize state variables
        _dropAmount = _drop;
        _dropInterval = _interval;
        weth = IWETH(_weth);
    }

    /// @notice Processes multiple drop requests for users identified by Telegram IDs and wallet addresses
    /// @dev Only callable by users with WITHDRAWER_ROLE; protected against reentrancy and when paused
    /// @param tgIds Array of Telegram user IDs for the drop requests
    /// @param accounts Array of wallet addresses to receive the WETH
    function requests(uint64[] calldata tgIds, address[] calldata accounts)
        external
        nonReentrant
        whenNotPaused
        onlyRole(WITHDRAWER_ROLE)
    {
        _requests(tgIds, accounts);
    }

    /// @notice Calculates the next allowed request time for a Telegram user ID
    /// @param tgId The Telegram user ID to check
    /// @return The UNIX timestamp (in seconds) when the user can make their next request
    function calculateNextRequest(uint64 tgId) public view virtual returns (uint256) {
        return _tgIds[tgId] + _dropInterval;
    }

    /// @notice Retrieves the current drop amount
    /// @return The amount of WETH distributed per request
    function getDropAmount() public view virtual returns (uint256) {
        return _dropAmount;
    }

    /// @notice Retrieves the current drop interval
    /// @return The time interval (in seconds) between allowed requests
    function getDropInterval() public view virtual returns (uint256) {
        return _dropInterval;
    }

    /// @notice Calculates the next allowed request time for a wallet address
    /// @param account The wallet address to check
    /// @return The UNIX timestamp (in seconds) when the address can make its next request
    function calculateNextRequest(address account) public view virtual returns (uint256) {
        return _accounts[account] + _dropInterval;
    }

    /// @notice Checks if a Telegram user ID is eligible to make a drop request
    /// @param tgId The Telegram user ID to check
    /// @return True if the user can request a drop, false otherwise
    function canRequest(uint64 tgId) public view virtual returns (bool) {
        bool isBlockedTgId = _blockedTgIds[tgId];
        uint256 nextAllowedRequestAt = calculateNextRequest(tgId);
        return !isBlockedTgId && block.timestamp >= nextAllowedRequestAt;
    }

    /// @notice Checks if a wallet address is eligible to make a drop request
    /// @param account The wallet address to check
    /// @return True if the address can request a drop, false otherwise
    function canRequest(address account) public view virtual returns (bool) {
        uint256 nextAllowedRequestAt = calculateNextRequest(account);
        return block.timestamp >= nextAllowedRequestAt;
    }

    /// @notice Pauses the contract, stopping all drop requests
    /// @dev Only callable by the contract owner when the contract is not paused
    function pause() external onlyOwner whenNotPaused {
        _pause();
    }

    /// @notice Unpauses the contract, resuming drop requests
    /// @dev Only callable by the contract owner when the contract is paused
    function unpause() external onlyOwner whenPaused {
        _unpause();
    }

    /// @notice Deposits ETH to the contract and wraps it into WETH
    /// @dev Only callable by the contract owner; converts ETH to WETH using the WETH contract
    function deposit() external payable onlyOwner {
        weth.deposit{value: msg.value}();
    }

    /// @notice Withdraws WETH from the contract and unwraps it to ETH for the recipient
    /// @dev Only callable by the contract owner; unwraps WETH and sends ETH to the recipient
    /// @param recipient The address to receive the withdrawn ETH
    /// @param amount The amount of WETH to withdraw and unwrap
    function withdraw(address recipient, uint256 amount) external onlyOwner {
        weth.withdraw(amount);
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Faucet: withdrawal failed");
    }

    /// @notice Recovers any stray ETH from the contract balance
    /// @dev Only callable by the contract owner; sends ETH to the owner
    function recover() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Faucet: no ETH to recover");
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Faucet: ETH recovery failed");
    }

    /// @notice Recovers any stray ERC20 tokens from the contract balance
    /// @dev Only callable by the contract owner; transfers tokens to the owner
    /// @param token The address of the ERC20 token to recover
    function recover(address token) external onlyOwner {
        uint256 balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "Faucet: no tokens to recover");
        IERC20(token).transfer(msg.sender, balance);
    }

    /// @notice Updates the amount of WETH distributed per drop request
    /// @dev Only callable by the contract owner; emits DropAmountChanged event
    /// @param newDrop The new drop amount
    function changeDrop(uint256 newDrop) external onlyOwner {
        _dropAmount = newDrop;
        emit DropAmountChanged(newDrop);
    }

    /// @notice Updates the time interval between allowed drop requests
    /// @dev Only callable by the contract owner; emits DropIntervalChanged event
    /// @param newInterval The new interval in seconds
    function changeInterval(uint256 newInterval) external onlyOwner {
        _dropInterval = newInterval;
        emit DropIntervalChanged(newInterval);
    }

    /// @notice Blocks a Telegram user ID, preventing drop requests
    /// @dev Only callable by the contract owner; emits TgIdBlocked event
    /// @param tgId The Telegram user ID to block
    function blockTgId(uint64 tgId) external onlyOwner {
        _updateTgIdBlockStatus(tgId, true);
    }

    /// @notice Unblocks a Telegram user ID, allowing drop requests
    /// @dev Only callable by the contract owner; emits TgIdUnblocked event
    /// @param tgId The Telegram user ID to unblock
    function unblockTgId(uint64 tgId) external onlyOwner {
        _updateTgIdBlockStatus(tgId, false);
    }

    /// @dev Internal function to update the block status of a Telegram user ID
    /// @param _tgId The Telegram user ID to update
    /// @param _isBlocked The new block status (true for blocked, false for unblocked)
    function _updateTgIdBlockStatus(uint64 _tgId, bool _isBlocked) internal {
        // Emit appropriate event based on block status
        if (_isBlocked) {
            emit TgIdBlocked(_tgId);
        } else {
            emit TgIdUnblocked(_tgId);
        }

        // Update the block status in the mapping
        _blockedTgIds[_tgId] = _isBlocked;
    }

    /// @dev Internal function to process multiple drop requests
    /// @param _userTgIds Array of Telegram user IDs for the drop requests
    /// @param _userAccounts Array of wallet addresses to receive the WETH
    function _requests(uint64[] memory _userTgIds, address[] memory _userAccounts) internal {
        // Ensure the input arrays have the same length
        require(_userTgIds.length == _userAccounts.length, "Faucet: mismatched length of _tgIds and _accounts");

        // Calculate the total WETH required for the drop requests
        uint256 requiredAmount = _dropAmount * _userTgIds.length;
        uint256 balance = weth.balanceOf(address(this));
        require(balance >= requiredAmount, "Faucet: insufficient WETH balance");

        // Unwrap WETH to ETH for distribution
        weth.withdraw(requiredAmount);

        // Process each drop request
        for (uint256 i = 0; i < _userAccounts.length; i++) {
            uint64 tgId = _userTgIds[i];
            address account = _userAccounts[i];

            // Skip if the user or account is not eligible for a drop
            if (canRequest(tgId) && canRequest(account)) {
                (bool success, ) = account.call{value: _dropAmount}("");
                require(success, "Faucet: drop failed");

                // Update claim timestamps for successful drops
                _tgIds[tgId] = block.timestamp;
                _accounts[account] = block.timestamp;
                emit FaucetDropped(tgId, account, _dropAmount);
            }
        }
    }
}
