///| Errors that bank-account operations can raise.
suberror AccountError {
  NonPositiveAmount(Int)
  InsufficientFunds(balance~ : Int, requested~ : Int)
} derive(Show, Eq)

///| A bank account holding a non-negative integer balance.
struct Account {
  mut balance : Int
}

///| Create a fresh account with a zero balance.
pub fn Account::new() -> Account {
  { balance: 0 }
}

///| Current balance. Always >= 0.
pub fn Account::balance(self : Account) -> Int {
  self.balance
}

///| Deposit a positive amount. Rejects amounts <= 0; on error the
///| balance is left unchanged.
pub fn Account::deposit(self : Account, amount : Int) -> Unit raise AccountError {
  guard amount > 0 else { raise NonPositiveAmount(amount) }
  self.balance = self.balance + amount
}

///| Withdraw a positive amount that does not exceed the balance.
///| Rejects amounts <= 0 and amounts greater than the balance; on
///| error the balance is left unchanged.
pub fn Account::withdraw(
  self : Account,
  amount : Int,
) -> Unit raise AccountError {
  guard amount > 0 else { raise NonPositiveAmount(amount) }
  guard amount <= self.balance else {
    raise InsufficientFunds(balance~=self.balance, requested~=amount)
  }
  self.balance = self.balance - amount
}
