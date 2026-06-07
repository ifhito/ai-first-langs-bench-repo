"""A simple bank account with deposit, withdraw, and balance operations."""


class BankAccountError(Exception):
    """Raised when an invalid bank account operation is attempted."""


class BankAccount:
    """A bank account holding a non-negative integer balance."""

    def __init__(self):
        self._balance = 0

    def balance(self):
        """Return the current balance."""
        return self._balance

    def deposit(self, amount):
        """Deposit a positive integer amount into the account."""
        self._validate_amount(amount)
        self._balance += amount

    def withdraw(self, amount):
        """Withdraw a positive integer amount, not exceeding the balance."""
        self._validate_amount(amount)
        if amount > self._balance:
            raise BankAccountError("withdrawal amount exceeds balance")
        self._balance -= amount

    @staticmethod
    def _validate_amount(amount):
        if not isinstance(amount, int) or isinstance(amount, bool):
            raise BankAccountError("amount must be an integer")
        if amount <= 0:
            raise BankAccountError("amount must be a positive integer")
