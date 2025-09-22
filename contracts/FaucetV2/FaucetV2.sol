// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >= 0.8.28;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { Pausable } from "@openzeppelin/contracts/utils/Pausable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import { FaucetRoles } from "./FaucetRoles.sol";
import { FaucetBase } from "./extensions/FaucetBase.sol";

contract FaucetV2 is EIP712, Pausable, ReentrancyGuard, FaucetRoles, FaucetBase {
    error InvalidLength();
    error DeadlineExpired(uint256 deadline);
    error NonceAlreadyUsed(uint256 nonce);
    error BadSignature(bytes signature);

    using ECDSA for bytes32;

    bytes32 public constant REQUEST_TYPEHASH = 
        keccak256("RequestFaucet(uint32[] users,address[] accounts,uint256 amount,uint256 deadline,uint256 nonce)");
    mapping (uint256 => bool) private _usedNonces;

    constructor(
        string memory name,
        string memory version,
        uint256 faucetAmount,
        uint256 faucetCooldown
    ) EIP712(name, version) FaucetBase(faucetAmount, faucetCooldown) payable {
        _grantRole(USER_MANAGER_ROLE, msg.sender);
        _grantRole(ACCOUNT_MANAGER_ROLE, msg.sender);
        _grantRole(REQUEST_DELEGATOR_ROLE, msg.sender);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function requests(
        uint32[] calldata users,
        address[] calldata accounts,
        uint256 deadline,
        uint256 nonce,
        bytes calldata signature
    ) external nonReentrant returns (bool) {
        if (users.length != accounts.length) revert InvalidLength();
        if (block.timestamp > deadline) revert DeadlineExpired(deadline);
        if (_usedNonces[nonce]) revert NonceAlreadyUsed(nonce);

        bytes32 hash = _hashTypedDataV4(keccak256(abi.encode(
            REQUEST_TYPEHASH,
            keccak256(abi.encodePacked(users)),
            keccak256(abi.encodePacked(accounts)),
            getFaucetAmount(),
            deadline,
            nonce
        )));

        address signer = hash.recover(signature);
        if (!_isRequestDelegator(signer)) revert BadSignature(signature);

        _usedNonces[nonce] = true;
        for (uint256 i = 0; i < users.length; i++) {
            // No need to revert here; just skip if criteria aren't met. We'll check it manually later from the user side.
            if (canRequest(users[i]) && canRequest(accounts[i])) {
                _request(users[i], accounts[i], getFaucetAmount());
            }
        }

        return true;
    }

    function withdraw(address recipient) external onlyRole(DEFAULT_ADMIN_ROLE) {
        (bool success, ) = recipient.call{value: address(this).balance}(new bytes(0));
    }

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {
        _unpause();
    }

    /// @inheritdoc FaucetBase
    function canRequest(uint32 user) public view virtual override returns (bool) {
        return !paused() && super.canRequest(user);
    }

    /// @inheritdoc FaucetBase
    function canRequest(address account) public view virtual override returns (bool) {
        return !paused() && super.canRequest(account);
    }

    receive() external payable {}
}
