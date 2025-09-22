// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

interface IAccountManager {
    event AccountBanned(address indexed account);
    event AccountUnbanned(address indexed account);

    function ban(address account) external;
    function unban(address account) external;
    function banned(address account) external view returns (bool);
    function getLastRequest(address account) external view returns (uint256);
}