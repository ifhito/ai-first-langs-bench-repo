// Blackbox tests covering all 14 specified cases.

// ---- SUCCESS cases (final balance) ----

test "case 1: fresh account is 0" {
  let a = @bankaccount.Account::new()
  assert_eq(a.balance(), 0)
}

test "case 2: deposit 100 => 100" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  assert_eq(a.balance(), 100)
}

test "case 3: deposit 100, deposit 50 => 150" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  a.deposit(50)
  assert_eq(a.balance(), 150)
}

test "case 4: deposit 100, withdraw 30 => 70" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  a.withdraw(30)
  assert_eq(a.balance(), 70)
}

test "case 5: deposit 100, withdraw 100 => 0" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  a.withdraw(100)
  assert_eq(a.balance(), 0)
}

test "case 6: deposit 50, deposit 50, withdraw 80 => 20" {
  let a = @bankaccount.Account::new()
  a.deposit(50)
  a.deposit(50)
  a.withdraw(80)
  assert_eq(a.balance(), 20)
}

// ---- ERROR cases (rejected AND balance unchanged) ----

test "case 7: fresh withdraw 10 rejected, balance 0" {
  let a = @bankaccount.Account::new()
  let r = try? a.withdraw(10)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 0)
}

test "case 8: deposit 100, withdraw 101 rejected, balance 100" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  let r = try? a.withdraw(101)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 100)
}

test "case 9: deposit -50 rejected, balance 0" {
  let a = @bankaccount.Account::new()
  let r = try? a.deposit(-50)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 0)
}

test "case 10: withdraw -50 rejected, balance 0" {
  let a = @bankaccount.Account::new()
  let r = try? a.withdraw(-50)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 0)
}

test "case 11: deposit 0 rejected, balance 0" {
  let a = @bankaccount.Account::new()
  let r = try? a.deposit(0)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 0)
}

test "case 12: withdraw 0 rejected, balance 0" {
  let a = @bankaccount.Account::new()
  let r = try? a.withdraw(0)
  assert_true(r is Err(_))
  assert_eq(a.balance(), 0)
}

// ---- INVARIANTS ----

test "case 13: balance never negative across a sequence" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  assert_true(a.balance() >= 0)
  let _ = try? a.withdraw(1000)
  assert_true(a.balance() >= 0)
  a.withdraw(100)
  assert_true(a.balance() >= 0)
  assert_eq(a.balance(), 0)
}

test "case 14: every error path leaves balance unchanged" {
  let a = @bankaccount.Account::new()
  a.deposit(100)
  let before = a.balance()
  let _ = try? a.deposit(0)
  assert_eq(a.balance(), before)
  let _ = try? a.deposit(-1)
  assert_eq(a.balance(), before)
  let _ = try? a.withdraw(0)
  assert_eq(a.balance(), before)
  let _ = try? a.withdraw(-1)
  assert_eq(a.balance(), before)
  let _ = try? a.withdraw(before + 1)
  assert_eq(a.balance(), before)
}
