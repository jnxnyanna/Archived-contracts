// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { IUserManager } from "../interfaces/IUserManager.sol";
import { FaucetRoles } from "../FaucetRoles.sol";

abstract contract UserManager is IUserManager, FaucetRoles {
    error RequestToBannedUser(uint32 user);
    error UserAlreadyBanned(uint32 user);
    error UserNotInBanned(uint32 user);

    struct User {
        uint256 lastRequest;
        bool banned;
    }

    mapping (uint32 => User) private _users;

    /// @inheritdoc IUserManager
    function ban(uint32 user) external onlyUserManager {
        if (banned(user)) revert UserAlreadyBanned(user);
        _updateBanned(user, true);
    }

    /// @inheritdoc IUserManager
    function unban(uint32 user) external onlyUserManager {
        if (!banned(user)) revert UserNotInBanned(user);
        _updateBanned(user, false);
    }

    /// @inheritdoc IUserManager
    function banned(uint32 user) public view returns (bool) {
        return _users[user].banned;
    }

    /// @inheritdoc IUserManager
    function getLastRequest(uint32 user) public view returns (uint256) {
        return _users[user].lastRequest;
    }

    function _updateLastRequest(uint32 _user, uint256 _lastRequest) internal {
        _users[_user].lastRequest = _lastRequest;
    }

    function _updateBanned(uint32 _user, bool _banned) internal {
        _users[_user].banned = _banned;
        if (_banned) emit UserBanned(_user);
        else emit UserUnbanned(_user);
    }
}