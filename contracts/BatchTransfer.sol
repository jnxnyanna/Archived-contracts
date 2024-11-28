/**
 * @notice Deployed contract can be found at https://sepolia.uniscan.xyz/address/0x1a11eb4f2c14a8fcecb4581f220f7dd6fe7c6d02#code
 */

// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

/**
 * @title BatchTransfer
 * @dev Contract to facilitate batch ETH and ERC20 transfers to multiple recipients.
 */
interface IERC20 {
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract BatchTransfer {
    address public immutable owner;

    event ETHTransferred(address indexed recipient, uint256 amount);
    event TokenTransferred(address indexed token, address indexed recipient, uint256 amount);

    /**
     * @dev Sets the owner of the contract to the deployer.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Modifier to validate the input requirements for batch transfers.
     * @param recipients Array of recipient addresses.
     * @param amounts Array of transfer amounts.
     * Requirements:
     * - `recipients` must not be empty.
     * - `recipients` length must not exceed 1000.
     * - `recipients` and `amounts` must have the same length.
     */
    modifier isMeetRequirements(
        address[] memory recipients,
        uint256[] memory amounts
    ) {
        require(
            recipients.length > 0 &&
            recipients.length <= 1000 &&
            amounts.length == recipients.length,
            "Invalid input parameters"
        );
        _;
    }

    /**
     * @dev Batch transfer ETH to multiple recipients with different amounts.
     * Requirements:
     * - Transfers must succeed, otherwise the transaction will revert.
     */
    function batchTransferETH(
        address[] memory recipients,
        uint256[] memory amounts
    ) external payable isMeetRequirements(recipients, amounts) {
        _batchTransferETH(recipients, amounts);
    }

    /**
     * @dev Batch transfer ETH to multiple recipients with the same amount.
     */
    function batchTransferETHWithSameAmount(
        address[] memory recipients,
        uint256 amount
    ) external payable {
        uint256[] memory amounts = new uint256[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            amounts[i] = amount;
        }

        _batchTransferETH(recipients, amounts);
    }

    /**
     * @dev Internal function to perform batch ETH transfers.
     * @param recipients Array of recipient addresses.
     * @param amounts Array of ETH amounts to transfer.
     * Requirements:
     * - The total ETH required must not exceed `msg.value`.
     */
    function _batchTransferETH(
        address[] memory recipients,
        uint256[] memory amounts
    ) internal isMeetRequirements(recipients, amounts) {
        uint256 requiredAmount;
        uint256 remainingAmount;

        // Calculate total required amount
        for (uint256 i = 0; i < amounts.length; i++) {
            requiredAmount += amounts[i];
        }

        require(msg.value >= requiredAmount, "Insufficient ETH provided");

        // Transfer ETH to recipients and check each transfer
        for (uint256 i = 0; i < recipients.length; i++) {
            (bool success, ) = recipients[i].call{ value: amounts[i] }("");
            require(success, "ETH transfer failed");
            emit ETHTransferred(recipients[i], amounts[i]);
        }

        // Refund any remaining ETH to the sender
        remainingAmount = msg.value - requiredAmount;
        if (remainingAmount > 0) {
            (bool refundSuccess, ) = msg.sender.call{value: remainingAmount}("");
            require(refundSuccess, "Refund failed");
        }
    }

    /**
     * @dev Batch transfer ERC20 tokens to multiple recipients with different amounts.
     * @param token Address of the ERC20 token contract.
     * @param recipients Array of recipient addresses.
     * @param amounts Array of token amounts to transfer.
     */
    function batchTransferERC20(
        IERC20 token,
        address[] memory recipients,
        uint256[] memory amounts
    ) external isMeetRequirements(recipients, amounts) {
        _batchTransferERC20(token, recipients, amounts);
    }

    /**
     * @dev Batch transfer ERC20 tokens to multiple recipients with the same amount.
     * @param token Address of the ERC20 token contract.
     * @param recipients Array of recipient addresses.
     * @param amount Token amount to send to each recipient.
     */
    function batchTransferERC20WithSameAmount(
        IERC20 token,
        address[] memory recipients,
        uint256 amount
    ) external {
        uint256[] memory amounts = new uint256[](recipients.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            amounts[i] = amount;
        }

        _batchTransferERC20(token, recipients, amounts);
    }

    /**
     * @dev Internal function to perform batch ERC20 transfers.
     * @param token Address of the ERC20 token contract.
     * @param recipients Array of recipient addresses.
     * @param amounts Array of token amounts to transfer.
     */
    function _batchTransferERC20(
        IERC20 token,
        address[] memory recipients,
        uint256[] memory amounts
    ) internal isMeetRequirements(recipients, amounts) {
        uint256 totalAmount;

        // Calculate total amount and validate balance and allowance
        for (uint256 i = 0; i < amounts.length; i++) {
            totalAmount += amounts[i];
        }

        require(token.balanceOf(msg.sender) >= totalAmount, "Insufficient token balance");
        require(
            token.allowance(msg.sender, address(this)) >= totalAmount,
            "Insufficient token allowance"
        );

        // Perform transfers and check success
        for (uint256 i = 0; i < recipients.length; i++) {
            bool success = token.transferFrom(msg.sender, recipients[i], amounts[i]);
            require(success, "Token transfer failed");
            emit TokenTransferred(address(token), recipients[i], amounts[i]);
        }
    }

    /**
     * @dev Withdraws all ETH from the contract to the owner's address.
     */
    function withdrawETH() external {
        uint256 amount = address(this).balance;

        (bool withdrawed, ) = owner.call{value: amount}("");
        require(withdrawed, "ETH withdrawal failed");

        emit ETHTransferred(owner, amount);
    }

    /**
     * @dev Allows the contract to receive ETH directly.
     */
    receive() external payable {}
}
