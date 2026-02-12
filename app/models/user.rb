class User < ApplicationRecord
  has_secure_password

  enum :role, { child: 0, parent: 1, admin: 2 }, default: :parent
  enum :color_scheme, { system: 0, light: 1, dark: 2 }, default: :system
  enum :light_theme, { white: 0, selenized_light: 1 }, default: :selenized_light
  enum :dark_theme, { black: 0, selenized_dark: 1 }, default: :selenized_dark

  has_one :child_profile, dependent: :destroy
  has_many :sessions, dependent: :destroy

  normalizes :email, with: -> email { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en nl] }
end
