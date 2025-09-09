// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IEnjoyoorsVaultError {
    error AccessControlBadConfirmation();
    error AccessControlUnauthorizedAccount(address account, bytes32 neededRole);
    error AddressEmptyCode(address target);
    error AddressInsufficientBalance(address account);
    error AlreadyClaimed();
    error AlreadyWhitelisted();
    error ClaimsAlreadyActive();
    error ClaimsPaused();
    error DepositsAlreadyActive();
    error DepositsPaused();
    error ExceedsLimit(uint256 tillLimit);
    error FailedInnerCall();
    error LessThanMinDeposit(uint256 minDeposit);
    error NotEnoughUserSupply(uint256 userSupply);
    error NotWhitelisted();
    error ReentrancyGuardReentrantCall();
    error SafeERC20FailedOperation(address token);
    error SupplyLimitDecreaseFailed(uint256 supplyLeft);
    error WithdrawalsAlreadyActive();
    error WithdrawalsPaused();
    error WrongApproverAddress();
    error WrongWithdrawalRequestId(uint256 lastRequestId);
    error ZeroAddress();
    error ZeroAmount();
}
