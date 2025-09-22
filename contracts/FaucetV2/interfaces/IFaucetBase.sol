// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { IUserManager } from "./IUserManager.sol";
import { IAccountManager } from "./IAccountManager.sol";

interface IFaucetBase is IUserManager, IAccountManager {
    event FaucetAmountUpdated(uint256 newFaucetAmount);
    event FaucetCooldownUpdated(uint256 newFaucetCooldown);
    event FaucetRequested(uint32 indexed user, address indexed account, uint256 amount);
    
    function changeFaucetAmount(uint256 newFaucetAmount) external;
    function changeFaucetCooldown(uint256 newFaucetCooldown) external;
    function getFaucetAmount() external view returns (uint256);
    function getFaucetCooldown() external view returns (uint256);
}
