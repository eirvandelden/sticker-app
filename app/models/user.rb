class User < ApplicationRecord
  include Role, Transferable

  has_many :sessions, dependent: :destroy
  has_secure_password validations: false

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def current?
    self == Current.user
  end

  def deactivate
    transaction do
      sessions.delete_all
      update! active: false, email_address: deactivated_email_address
    end
  end

  has_secure_password

  enum :role, { child: 0, parent: 1, admin: 2 }, default: :parent
  enum :color_scheme, { system: 0, light: 1, dark: 2 }, default: :system
  enum :light_theme, { white: 0, selenized_light: 1 }, default: :selenized_light
  enum :dark_theme, { black: 0, selenized_dark: 1 }, default: :selenized_dark

  has_one :child_profile, dependent: :destroy
  has_many :sessions, dependent: :destroy

  after_create :provision_child_profile, if: :child?

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en nl it] }

  private
    def deactivated_email_address
      email_address&.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
    end

    def provision_child_profile
      create_child_profile!
    end
end
