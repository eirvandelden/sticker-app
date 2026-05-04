class Session < ApplicationRecord
  belongs_to :user

  before_create do
    self.token = SecureRandom.base58(32)
  end
end
