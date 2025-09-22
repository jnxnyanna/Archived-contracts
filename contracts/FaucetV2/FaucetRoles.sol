// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { AccessControl } from "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract FaucetRoles is AccessControl {
    error NotUserManager();
    error NotAccountManager();

    bytes32 public constant USER_MANAGER_ROLE = 
        keccak256("FaucetRoles.USER_MANAGER_ROLE");
    bytes32 public constant ACCOUNT_MANAGER_ROLE =
        keccak256("FaucetRoles.ACCOUNT_MANAGER_ROLE");
    bytes32 public constant REQUEST_DELEGATOR_ROLE =
        keccak256("FaucetRoles.REQUEST_DELEGATOR_ROLE");
    
    function _isRequestDelegator(address _account) internal view returns (bool) {
        return hasRole(REQUEST_DELEGATOR_ROLE, _account);
    }

    modifier onlyUserManager {
        if (!hasRole(USER_MANAGER_ROLE, msg.sender)) revert NotUserManager();
        _;
    }

    modifier onlyAccountManager {
        if (!hasRole(ACCOUNT_MANAGER_ROLE, msg.sender)) revert NotAccountManager();
        _;
    }
}
