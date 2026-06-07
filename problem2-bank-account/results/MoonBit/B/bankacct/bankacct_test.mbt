// Blackbox tests covering all 14 spec cases. Uses `@bankacct` to import.

///| Helper: assert an operation raised an error AND left balance unchanged.
fn expect_unchanged(
  acc : @bankacct.Account,
  before : Int,
  op : (@bankacct.Account) -> Unit raise @bankacct.AccountError,
) -> Unit raise {
  let raised = try {
    op(acc)
    false
  } catch {
    _ => true
  }
  assert_true(raised) // operation must be rejected
  assert_eq(acc.balance(), before) // balance must be unchanged
}

///|
test "1: fresh account balance is 0" {
  let a = @bankacct.Account::new()
  assert_eq(a.balance(), 0)
}

///|
test "2: deposit 100 => 100" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  assert_eq(a.balance(), 100)
}

///|
test "3: deposit 100, deposit 50 => 150" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  a.deposit(50)
  assert_eq(a.balance(), 150)
}

///|
test "4: deposit 100, withdraw 30 => 70" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  a.withdraw(30)
  assert_eq(a.balance(), 70)
}

///|
test "5: deposit 100, withdraw 100 => 0" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  a.withdraw(100)
  assert_eq(a.balance(), 0)
}

///|
test "6: deposit 50, deposit 50, withdraw 80 => 20" {
  let a = @bankacct.Account::new()
  a.deposit(50)
  a.deposit(50)
  a.withdraw(80)
  assert_eq(a.balance(), 20)
}

///|
test "7: fresh, withdraw 10 rejected, balance 0" {
  let a = @bankacct.Account::new()
  expect_unchanged(a, 0, (x) => x.withdraw(10))
}

///|
test "8: deposit 100, withdraw 101 rejected, balance 100" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  expect_unchanged(a, 100, (x) => x.withdraw(101))
}

///|
test "9: deposit -50 rejected, balance 0" {
  let a = @bankacct.Account::new()
  expect_unchanged(a, 0, (x) => x.deposit(-50))
}

///|
test "10: withdraw -50 rejected, balance 0" {
  let a = @bankacct.Account::new()
  expect_unchanged(a, 0, (x) => x.withdraw(-50))
}

///|
test "11: deposit 0 rejected, balance 0" {
  let a = @bankacct.Account::new()
  expect_unchanged(a, 0, (x) => x.deposit(0))
}

///|
test "12: withdraw 0 rejected, balance 0" {
  let a = @bankacct.Account::new()
  expect_unchanged(a, 0, (x) => x.withdraw(0))
}

///|
test "13: balance never negative across a mixed sequence" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  // attempt several invalid operations; none may push balance below 0
  for amt in [200, -1, 0, 101] {
    let _ = try? a.withdraw(amt)
    assert_true(a.balance() >= 0)
  }
  a.withdraw(100)
  assert_eq(a.balance(), 0)
  assert_true(a.balance() >= 0)
}

///|
test "14: each error case leaves balance unchanged" {
  let a = @bankacct.Account::new()
  a.deposit(100)
  // every one of these must be rejected and leave balance at 100
  expect_unchanged(a, 100, (x) => x.deposit(0))
  expect_unchanged(a, 100, (x) => x.deposit(-5))
  expect_unchanged(a, 100, (x) => x.withdraw(0))
  expect_unchanged(a, 100, (x) => x.withdraw(-5))
  expect_unchanged(a, 100, (x) => x.withdraw(101))
  assert_eq(a.balance(), 100)
}
