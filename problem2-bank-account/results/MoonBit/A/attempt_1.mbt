// Bank account: deposit / withdraw / balance.
// Amounts must be positive integers; withdrawals cannot exceed the balance.
// On any error the balance is left unchanged and stays >= 0.

///|
/// Errors that bank operations can fail with.
pub suberror BankError {
  NonPositiveAmount
  InsufficientFunds
} derive(Debug, Eq)

///|
/// A bank account holding a non-negative integer balance.
pub struct Account {
  mut balance : Int
}

///|
/// Create a fresh account with a zero balance.
pub fn Account::new() -> Account {
  { balance: 0 }
}

///|
/// Current balance. Always >= 0.
pub fn Account::balance(self : Account) -> Int {
  self.balance
}

///|
/// Deposit a positive amount. Rejects amounts <= 0.
pub fn Account::deposit(self : Account, amount : Int) -> Unit raise BankError {
  if amount <= 0 {
    raise NonPositiveAmount
  }
  self.balance = self.balance + amount
}

///|
/// Withdraw a positive amount that does not exceed the balance.
/// Rejects amounts <= 0 and amounts greater than the current balance.
pub fn Account::withdraw(self : Account, amount : Int) -> Unit raise BankError {
  if amount <= 0 {
    raise NonPositiveAmount
  }
  if amount > self.balance {
    raise InsufficientFunds
  }
  self.balance = self.balance - amount
}
