// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEnjoyoorsVaultEvent {
    event Deposit(address indexed token, address indexed user, uint256 amount);
    event MinDepositChanged(address indexed token, uint256 _old, uint256 _new);
    event NewTokenListed(address newToken);
    event PauseClaims(address token);
    event PauseDeposits(address token);
    event PauseWithdrawals(address token);
    event ResumeClaims(address token);
    event ResumeDeposits(address token);
    event ResumeWithdrawals(address token);
    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );
    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );
    event SupplyLimitDecreased(address indexed token, uint256 delta);
    event SupplyLimitIncreased(address indexed token, uint256 delta);
    event WithdrawalApproverChanged(address _old, address _new);
    event WithdrawalClaimed(uint256 indexed requestId, uint256 amount);
    event WithdrawalRequested(
        address indexed token,
        address indexed user,
        uint256 indexed requestId,
        uint256 amount
    );
}
