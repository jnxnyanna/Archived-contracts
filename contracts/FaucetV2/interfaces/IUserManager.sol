// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

interface IUserManager {
    event UserBanned(uint32 indexed user);
    event UserUnbanned(uint32 indexed user);

    function ban(uint32 user) external;
    function unban(uint32 user) external;
    function banned(uint32 user) external view returns (bool);
    function getLastRequest(uint32 user) external view returns (uint256);
}