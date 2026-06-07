'use strict';

const { BankAccount } = require('./attempt_1.js');

let pass = 0;
let total = 0;

function check(name, cond) {
  total++;
  if (cond) {
    pass++;
    console.log(`PASS  ${name}`);
  } else {
    console.log(`FAIL  ${name}`);
  }
}

// --- SUCCESS cases: verify final balance ---

check('1 fresh => 0', (() => {
  const a = new BankAccount();
  return a.balance() === 0;
})());

check('2 deposit(100) => 100', (() => {
  const a = new BankAccount();
  a.deposit(100);
  return a.balance() === 100;
})());

check('3 deposit(100),deposit(50) => 150', (() => {
  const a = new BankAccount();
  a.deposit(100);
  a.deposit(50);
  return a.balance() === 150;
})());

check('4 deposit(100),withdraw(30) => 70', (() => {
  const a = new BankAccount();
  a.deposit(100);
  a.withdraw(30);
  return a.balance() === 70;
})());

check('5 deposit(100),withdraw(100) => 0', (() => {
  const a = new BankAccount();
  a.deposit(100);
  a.withdraw(100);
  return a.balance() === 0;
})());

check('6 deposit(50),deposit(50),withdraw(80) => 20', (() => {
  const a = new BankAccount();
  a.deposit(50);
  a.deposit(50);
  a.withdraw(80);
  return a.balance() === 20;
})());

// --- ERROR cases: verify an error was thrown AND balance unchanged ---

function expectThrowUnchanged(name, expectedBalance, setup, badOp) {
  const a = new BankAccount();
  setup(a);
  const before = a.balance();
  let threw = false;
  try {
    badOp(a);
  } catch (e) {
    threw = true;
  }
  check(name, threw && a.balance() === before && a.balance() === expectedBalance);
}

expectThrowUnchanged('7 fresh,withdraw(10) => 0', 0,
  () => {}, (a) => a.withdraw(10));

expectThrowUnchanged('8 deposit(100),withdraw(101) => 100', 100,
  (a) => a.deposit(100), (a) => a.withdraw(101));

expectThrowUnchanged('9 deposit(-50) => 0', 0,
  () => {}, (a) => a.deposit(-50));

expectThrowUnchanged('10 withdraw(-50) => 0', 0,
  () => {}, (a) => a.withdraw(-50));

expectThrowUnchanged('11 deposit(0) => 0', 0,
  () => {}, (a) => a.deposit(0));

expectThrowUnchanged('12 withdraw(0) => 0', 0,
  () => {}, (a) => a.withdraw(0));

// --- INVARIANT cases ---

// 13: balance never negative across a whole run of mixed operations.
check('13 balance never negative across run', (() => {
  const a = new BankAccount();
  const ops = [
    () => a.deposit(100),
    () => a.withdraw(30),
    () => a.withdraw(200), // rejected
    () => a.deposit(10),
    () => a.withdraw(80),
    () => a.deposit(0),    // rejected
    () => a.withdraw(0),   // rejected
  ];
  for (const op of ops) {
    try { op(); } catch (e) { /* rejected ops are fine */ }
    if (a.balance() < 0) return false;
  }
  return a.balance() >= 0;
})());

// 14: every error case (7-12) leaves balance unchanged.
check('14 all error cases leave balance unchanged', (() => {
  const scenarios = [
    { setup: () => {}, expect: 0, op: (a) => a.withdraw(10) },
    { setup: (a) => a.deposit(100), expect: 100, op: (a) => a.withdraw(101) },
    { setup: () => {}, expect: 0, op: (a) => a.deposit(-50) },
    { setup: () => {}, expect: 0, op: (a) => a.withdraw(-50) },
    { setup: () => {}, expect: 0, op: (a) => a.deposit(0) },
    { setup: () => {}, expect: 0, op: (a) => a.withdraw(0) },
  ];
  for (const s of scenarios) {
    const a = new BankAccount();
    s.setup(a);
    const before = a.balance();
    let threw = false;
    try { s.op(a); } catch (e) { threw = true; }
    if (!threw) return false;
    if (a.balance() !== before) return false;
    if (a.balance() !== s.expect) return false;
  }
  return true;
})());

console.log(`\nPASS ${pass}/${total}`);
process.exit(pass === total ? 0 : 1);
