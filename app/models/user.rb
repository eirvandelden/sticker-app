class User < ApplicationRecord
  include Role, Transferable

  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  MAX_AVATAR_SIZE = 5.megabytes

  has_many :sessions, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  def current?
    self == Current.user
  end

  def deactivate
    transaction do
      sessions.delete_all
      update! active: false, email: deactivated_email
    end
  end

  def avatar_displayable?
    avatar.attached? && avatar.attachment.persisted?
  end

  has_secure_password

  enum :role, { child: 0, parent: 1, admin: 2 }, default: :parent
  enum :color_scheme, { system: 0, light: 1, dark: 2 }, default: :system
  enum :light_theme, { white: 0, selenized_light: 1 }, default: :selenized_light
  enum :dark_theme, { black: 0, selenized_dark: 1 }, default: :selenized_dark

  has_one :child_profile, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true
  validate :acceptable_avatar

  after_create :ensure_child_profile, if: :child?

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en nl it] }

  def ensure_child_profile
    return child_profile if child_profile.present?

    create_child_profile!
  end

  private

  def acceptable_avatar
    return unless avatar.attached?

    validate_avatar_content_type
    validate_avatar_size
  end

  def validate_avatar_content_type
    return if AVATAR_CONTENT_TYPES.include?(avatar.blob.content_type)

    errors.add(:avatar, :invalid_content_type)
  end

  def validate_avatar_size
    return if avatar.blob.byte_size <= MAX_AVATAR_SIZE

    errors.add(:avatar, :file_size_too_large)
  end

  def deactivated_email
    email&.gsub(/@/, "-deactivated-#{SecureRandom.uuid}@")
  end
end
