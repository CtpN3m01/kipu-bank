// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title  KipuBank – Simple vault bank
 * @author Saymon Porras Briones
 * @notice Allows users to deposit and withdraw ETH with a per-tx limit.
 * @dev    Implements the Checks-Effects-Interactions pattern.
 */

contract KipuBank {
    ///// -- ERRORS -- /////
    /// @notice Thrown when `msg.value` is zero.
    error ZeroAmount();

    /// @notice Thrown when the contract balance would exceed the global cap (`bankCap`).
    error BankCapExceeded();

    /// @notice Thrown when the requested withdrawal exceeds the per‑transaction limit (`withdrawLimit`).
    error WithdrawLimitExceeded();

    /// @notice Thrown when the caller’s vault balance is insufficient for the withdrawal.
    error InsufficientBalance();

    ///// -- STATE VARIABLES -- /////
    /// @notice Maximum amount (wei) a user can withdraw per transaction.
    uint256 public immutable withdrawLimit;

    /// @notice Maximum ETH the contract may hold in total.
    uint256 public immutable bankCap;

    /// @dev User vault balances.
    mapping(address => uint256) private _vault;

    /// @notice Number of deposits per user.
    mapping(address => uint256) public depositCount;

    /// @notice Number of withdrawals per user.
    mapping(address => uint256) public withdrawalCount;

    /// @notice Cumulative ETH ever deposited into the contract (wei).
    uint256 public totalDeposited;

    /// @notice Cumulative ETH ever withdrawn from the contract (wei).
    uint256 public totalWithdrawn;

    ///// -- EVENTS -- /////
    /// @notice Emitted when a user deposits ETH.
    event Deposited(address indexed user, uint256 amount);

    /// @notice Emitted when a user withdraws ETH.
    event Withdrawn(address indexed user, uint256 amount);

    //// -- CONSTRUCTOR -- /////
    /// @dev Constructor sets the withdrawal limit and bank capacity
    /// @param _withdrawLimit Per-tx withdrawal ceiling (wei).
    /// @param _bankCap Global ETH cap (wei).
    constructor(uint256 _withdrawLimit, uint256 _bankCap) {
        require(_withdrawLimit > 0 && _bankCap > 0, "invalid params");
        withdrawLimit = _withdrawLimit;
        bankCap = _bankCap;
    }

    ///// -- MODIFIERS -- /////
    /// @dev Reverts if the contract balance exceeds `bankCap` after receiving ETH.
    modifier withinBankCap() {
        if (address(this).balance > bankCap) revert BankCapExceeded();
        _;
    }

    ///// -- PRIVATE HELPER -- /////
    /**
     * @dev Updates vault balance and counters after a successful deposit.
     * @param user   Address whose vault is credited.
     * @param amount Amount (wei) deposited.
     */
    function _recordDeposit(address user, uint256 amount) private {
        _vault[user] += amount;
        depositCount[user] += 1;
        totalDeposited += amount;
    }

    /**
     * @dev Updates vault balance and counters after a successful withdrawal.
     * @param user   Address whose vault is debited.
     * @param amount Amount (wei) withdrawn.
     */
    function _recordWithdrawal(address user, uint256 amount) private {
        _vault[user] -= amount;
        withdrawalCount[user] += 1;
        totalWithdrawn += amount;
    }
    
    ///// -- EXTERNAL FUNCTIONS -- /////
    /**
    * @notice Deposit native ETH into the caller’s vault.
    * @dev    Reverts with {ZeroAmount} if `msg.value` is zero.
    *         The {withinBankCap} modifier handles the {BankCapExceeded} case.
    */
    function deposit() external payable withinBankCap {
        // ---------- CHECKS ----------
        if (msg.value == 0) revert ZeroAmount();

        // ---------- EFFECTS ----------
        _recordDeposit(msg.sender, msg.value);

        // ---------- INTERACTIONS ----------
        // No external calls in this function.

        emit Deposited(msg.sender, msg.value);
    }

    /**
     * @notice Withdraw part of your vault balance.
     * @param amount Amount of ETH (wei) to withdraw.
     * @dev    Follows Checks-Effects-Interactions. See {ZeroAmount},
     *         {WithdrawLimitExceeded}, {InsufficientBalance} errors.
     */
    function withdraw(uint256 amount) external {
        // ---------- CHECKS ----------
        if (amount == 0) revert ZeroAmount();
        if (amount > withdrawLimit) revert WithdrawLimitExceeded();
        if (amount > _vault[msg.sender]) revert InsufficientBalance();

        // ---------- EFFECTS ----------
        _recordWithdrawal(msg.sender, amount);

        // ---------- INTERACTIONS ----------
        (bool ok, ) = msg.sender.call{value: amount}("");
        require(ok, "ETH transfer failed");

        emit Withdrawn(msg.sender, amount);
    }

    /**
    * @notice Returns the vault balance of a user.
    * @dev View function to check user balance
    * @param user Address of the user
    * @return uint256 Balance of the user
    */
    function vaultBalance(address user) external view returns (uint256) {
        return _vault[user];
    }
}