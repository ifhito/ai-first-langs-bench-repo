"""Test runner for the BankAccount implementation (14 cases)."""

from attempt_1 import BankAccount, BankAccountError


def run():
    results = []

    def check(name, condition):
        results.append((name, condition))

    # --- SUCCESS cases: verify final balance ---
    a = BankAccount()
    check("1: fresh balance == 0", a.balance() == 0)

    a = BankAccount()
    a.deposit(100)
    check("2: deposit(100) == 100", a.balance() == 100)

    a = BankAccount()
    a.deposit(100)
    a.deposit(50)
    check("3: deposit(100)+deposit(50) == 150", a.balance() == 150)

    a = BankAccount()
    a.deposit(100)
    a.withdraw(30)
    check("4: deposit(100)+withdraw(30) == 70", a.balance() == 70)

    a = BankAccount()
    a.deposit(100)
    a.withdraw(100)
    check("5: deposit(100)+withdraw(100) == 0", a.balance() == 0)

    a = BankAccount()
    a.deposit(50)
    a.deposit(50)
    a.withdraw(80)
    check("6: deposit(50)+deposit(50)+withdraw(80) == 20", a.balance() == 20)

    # --- ERROR cases: raise AND balance unchanged ---
    def expect_error(name, account, op, expected_balance):
        before = account.balance()
        raised = False
        try:
            op()
        except BankAccountError:
            raised = True
        except Exception:
            raised = False  # wrong exception type counts as failure
        unchanged = account.balance() == before == expected_balance
        check(name, raised and unchanged)

    a = BankAccount()
    expect_error("7: fresh withdraw(10) rejected, balance 0", a, lambda: a.withdraw(10), 0)

    a = BankAccount()
    a.deposit(100)
    expect_error("8: deposit(100)+withdraw(101) rejected, balance 100", a, lambda: a.withdraw(101), 100)

    a = BankAccount()
    expect_error("9: deposit(-50) rejected, balance 0", a, lambda: a.deposit(-50), 0)

    a = BankAccount()
    expect_error("10: withdraw(-50) rejected, balance 0", a, lambda: a.withdraw(-50), 0)

    a = BankAccount()
    expect_error("11: deposit(0) rejected, balance 0", a, lambda: a.deposit(0), 0)

    a = BankAccount()
    expect_error("12: withdraw(0) rejected, balance 0", a, lambda: a.withdraw(0), 0)

    # --- INVARIANT cases ---
    # 13: balance never negative across a whole run
    a = BankAccount()
    ops = [
        ("deposit", 100), ("withdraw", 30), ("withdraw", 1000),
        ("deposit", 0), ("withdraw", 70), ("deposit", 5),
    ]
    never_negative = a.balance() >= 0
    for kind, amt in ops:
        try:
            getattr(a, kind)(amt)
        except BankAccountError:
            pass
        if a.balance() < 0:
            never_negative = False
    check("13: balance never negative across run", never_negative)

    # 14: every error case leaves balance unchanged
    a = BankAccount()
    a.deposit(200)
    unchanged_all = True
    for kind, amt in [("withdraw", 999), ("deposit", -1), ("withdraw", -1),
                      ("deposit", 0), ("withdraw", 0)]:
        before = a.balance()
        try:
            getattr(a, kind)(amt)
        except BankAccountError:
            pass
        if a.balance() != before:
            unchanged_all = False
    check("14: error cases leave balance unchanged", unchanged_all)

    # --- Report ---
    passed = 0
    for name, ok in results:
        print(f"{'PASS' if ok else 'FAIL'}  {name}")
        if ok:
            passed += 1
    print(f"PASS {passed}/{len(results)}")


if __name__ == "__main__":
    run()
