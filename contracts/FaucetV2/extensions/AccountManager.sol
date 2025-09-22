// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { IAccountManager } from "../interfaces/IAccountManager.sol";
import { FaucetRoles } from "../FaucetRoles.sol";

abstract contract AccountManager is IAccountManager, FaucetRoles {
    error RequestToBannedAccount(address account);
    error AccountAlreadyBanned(address account);
    error AccountNotInBanned(address account);

    struct Account {
        uint256 lastRequest;
        bool banned;
    }

    mapping (address => Account) private _accounts;

    /// @inheritdoc IAccountManager
    function ban(address account) external onlyAccountManager {
        if (banned(account)) revert AccountAlreadyBanned(account);
        _updateBanned(account, true);
    }

    /// @inheritdoc IAccountManager
    function unban(address account) external onlyAccountManager {
        if (!banned(account)) revert AccountNotInBanned(account);
        _updateBanned(account, false);
    }

    /// @inheritdoc IAccountManager
    function banned(address account) public view returns (bool) {
        return _accounts[account].banned;
    }

    /// @inheritdoc IAccountManager
    function getLastRequest(address account) public view returns (uint256) {
        return _accounts[account].lastRequest;
    }

    function _updateLastRequest(address _account, uint256 _lastRequest) internal {
        _accounts[_account].lastRequest = _lastRequest;
    }

    function _updateBanned(address _account, bool _banned) internal {
        _accounts[_account].banned = _banned;
        if (_banned) emit AccountBanned(_account);
        else emit AccountUnbanned(_account);
    }
}