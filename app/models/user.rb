class User < ApplicationRecord
  has_secure_password

  enum :role, { child: 0, parent: 1 }

  has_one :child_profile, dependent: :destroy

  validates :email, presence: true, uniqueness: true
end
