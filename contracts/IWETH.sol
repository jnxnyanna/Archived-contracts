// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

interface IWETH {
  /// @notice IWETH deposit function
  function deposit() external payable;

  /// @notice IWETH withdrawal function
  /// @param wad Withdrawal amount in wei
  function withdraw(uint wad) external;

  /// @notice IWETH balanceOf function 
  /// @param guy Wallet address
  function balanceOf(address guy) external view returns (uint);
}