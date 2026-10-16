# Is a stub for a future transfer of money between accounts.
class Transfer < ApplicationRecord
  # TODO: Add a relation with another transaction with a validation that that transfer goes to other way
  # TODO: Add a validator that verifies both accounts are by the same owner.
end
