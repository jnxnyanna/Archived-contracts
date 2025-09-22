// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { IFaucetBase } from "../interfaces/IFaucetBase.sol";
import { UserManager } from "./UserManager.sol";
import { AccountManager } from "./AccountManager.sol";

abstract contract FaucetBase is IFaucetBase, UserManager, AccountManager {
    error UserInCooldown(uint32 user, uint256 remainingTime);
    error AccountInCooldown(address account, uint256 remainingTime);
    error InsufficientFaucetBalance(uint256 balance, uint256 needed);
    error RequestCancelled(uint32 user, address account);

    uint256 private _faucetAmount;
    uint256 private _faucetCooldown;

    constructor(uint256 faucetAmount, uint256 faucetCooldown) {
        _faucetAmount = faucetAmount;
        _faucetCooldown = faucetCooldown;
    }

    function canRequest(uint32 user) public view virtual returns (bool) {
        return !banned(user) && block.timestamp >= getNextRequest(user);
    }

    function canRequest(address account) public view virtual returns (bool) {
        return !banned(account) && block.timestamp >= getNextRequest(account);
    }

    function getNextRequest(uint32 user) public view returns (uint256) {
        return getLastRequest(user) + _faucetCooldown;
    }

    function getNextRequest(address account) public view returns (uint256) {
        return getLastRequest(account) + _faucetCooldown;
    }

    /// @inheritdoc IFaucetBase
    function changeFaucetAmount(uint256 newFaucetAmount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _faucetAmount = newFaucetAmount;
        emit FaucetAmountUpdated(newFaucetAmount);
    }

    /// @inheritdoc IFaucetBase
    function changeFaucetCooldown(uint256 newFaucetCooldown) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _faucetCooldown = newFaucetCooldown;
        emit FaucetCooldownUpdated(newFaucetCooldown);
    }

    /// @inheritdoc IFaucetBase
    function getFaucetAmount() public view returns (uint256) {
        return _faucetAmount;
    }

    /// @inheritdoc IFaucetBase
    function getFaucetCooldown() public view returns (uint256) {
        return _faucetCooldown;
    }

    function _request(uint32 _user, address _account, uint256 _amount) internal virtual {
        if (banned(_user)) revert RequestToBannedUser(_user);
        if (banned(_account)) revert RequestToBannedAccount(_account);
        if (block.timestamp < getNextRequest(_user)) revert UserInCooldown(_user, getNextRequest(_user) - getLastRequest(_user));
        if (block.timestamp < getNextRequest(_account)) revert AccountInCooldown(_account, getNextRequest(_account) - getLastRequest(_account));
        if (address(this).balance < _amount) revert InsufficientFaucetBalance(address(this).balance, _amount);

        (bool success, ) = _account.call{value: _amount}(new bytes(0));
        if (!success) revert RequestCancelled(_user, _account);

        uint256 timestamp = block.timestamp;
        _updateLastRequest(_user, timestamp);
        _updateLastRequest(_account, timestamp);
        emit FaucetRequested(_user, _account, _amount);
    }
}
