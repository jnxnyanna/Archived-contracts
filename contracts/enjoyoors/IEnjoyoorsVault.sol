// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IEnjoyoorsVaultEvent.sol";
import "./IEnjoyoorsVaultError.sol";

interface IEnjoyoorsVault is IEnjoyoorsVaultEvent, IEnjoyoorsVaultError {
    struct WithdrawalRequest {
        uint256 amount;
        address user;
        address token;
        uint184 timestamp;
        bool claimed;
    }

    function CLAIM_PAUSE_ROLE() external view returns (bytes32);

    function CLAIM_RESUME_ROLE() external view returns (bytes32);

    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    function DEPOSIT_PAUSE_ROLE() external view returns (bytes32);

    function DEPOSIT_RESUME_ROLE() external view returns (bytes32);

    function SETUP_ROLE() external view returns (bytes32);

    function TOKEN_LISTER_ROLE() external view returns (bytes32);

    function WITHDRAWAL_PAUSE_ROLE() external view returns (bytes32);

    function WITHDRAWAL_RESUME_ROLE() external view returns (bytes32);

    function changeMinDeposit(address token, uint256 newMinDeposit) external;

    function changeWithdrawalApprover(address newWithdrawalApprover) external;

    function claimWithdrawal(uint256 requestId, bytes memory approverData)
        external
        returns (address token, uint256 amount);

    function claimsPaused(address token) external view returns (bool);

    function decreaseSupplyLimit(address token, uint256 delta) external;

    function deposit(address token, uint256 amount) external;

    function depositsPaused(address token) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function getWithdrawalRequestById(uint256 requestId)
        external
        view
        returns (IEnjoyoorsVault.WithdrawalRequest memory);

    function grantRole(bytes32 role, address account) external;

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

function increaseSupplyLimit(address token, uint256 delta) external;

    function isWhitelistedToken(address token) external view returns (bool);

    function lastRequestId() external view returns (uint256);

    function listToken(address token) external;

    function minDeposit(address token) external view returns (uint256);

    function pauseClaim(address token) external;

    function pauseDeposit(address token) external;

    function pauseWithdrawal(address token) external;

    function renounceRole(bytes32 role, address callerConfirmation) external;

    function requestWithdrawal(address token, uint256 amount)
        external
        returns (uint256 requestId);

    function resumeClaim(address token) external;

    function resumeDeposit(address token) external;

    function resumeWithdrawal(address token) external;

    function revokeRole(bytes32 role, address account) external;

    function supplyTillLimit(address token) external view returns (uint256);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function totalSupply(address token) external view returns (uint256);

    function userSupply(address token, address user)
        external
        view
        returns (uint256);

    function withdrawalApprover() external view returns (address);

    function withdrawalsPaused(address token) external view returns (bool);
}
