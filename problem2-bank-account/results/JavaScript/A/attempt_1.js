'use strict';

/**
 * A simple bank account.
 *
 * - Balance starts at 0.
 * - Deposits and withdrawals must be positive integers.
 * - A withdrawal may not exceed the current balance.
 * - The balance is always >= 0.
 */
class BankAccount {
  #balance = 0;

  /**
   * Validate that an amount is a positive integer.
   * @param {number} amount
   * @param {string} op operation name, used in the error message
   */
  static #assertPositiveInteger(amount, op) {
    if (typeof amount !== 'number' || !Number.isInteger(amount)) {
      throw new Error(`${op} amount must be an integer`);
    }
    if (amount <= 0) {
      throw new Error(`${op} amount must be positive`);
    }
  }

  /**
   * Deposit a positive integer amount.
   * @param {number} amount
   */
  deposit(amount) {
    BankAccount.#assertPositiveInteger(amount, 'deposit');
    this.#balance += amount;
  }

  /**
   * Withdraw a positive integer amount that does not exceed the balance.
   * @param {number} amount
   */
  withdraw(amount) {
    BankAccount.#assertPositiveInteger(amount, 'withdraw');
    if (amount > this.#balance) {
      throw new Error('insufficient funds');
    }
    this.#balance -= amount;
  }

  /**
   * @returns {number} the current balance
   */
  balance() {
    return this.#balance;
  }
}

module.exports = { BankAccount };
