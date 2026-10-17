# Represents a family member who signs in as an administrator, parent or child.
class User < ApplicationRecord
  include Appkit::Transferable
  include Role
  include Appkit::UserTheming
  include Appkit::Authenticatable

  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  MAX_AVATAR_SIZE = 5.megabytes

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  # Tells whether this user is the signed-in user.
  # @rbs () -> bool
  def current?
    self == Current.user
  end

  # Tells whether the avatar is attached and saved.
  # @rbs () -> bool
  def avatar_displayable?
    avatar.attached? && avatar.attachment.persisted?
  end

  enum :role, { child: 0, parent: 1, admin: 2 }, default: :parent

  has_one :child_profile, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true
  validate :acceptable_avatar

  after_save :provision_child_profile

  normalizes :email, with: ->(email) { email.strip.downcase }

  validates :email, presence: true, uniqueness: true
  validates :locale, inclusion: { in: %w[en nl it] }

  # Returns the child profile, creating it if missing.
  # @rbs () -> ChildProfile
  def ensure_child_profile
    child_profile || create_child_profile!
  end

  private
  # Validates the type and size of an attached avatar.
  # @rbs () -> void
  def acceptable_avatar
    return unless avatar.attached?

    validate_avatar_content_type
    validate_avatar_size
  end

  # Validates that the avatar is an allowed image type.
  # @rbs () -> void
  def validate_avatar_content_type
    return if AVATAR_CONTENT_TYPES.include?(detected_avatar_content_type)

    errors.add(:avatar, :invalid_content_type)
  end

  # Detects the avatar's type from its content, not its file name.
  # @rbs () -> String?
  def detected_avatar_content_type
    io = avatar_upload_io
    Marcel::MimeType.for(io)
  ensure
    io&.rewind if io.respond_to?(:rewind)
  end

  # Returns a readable stream of the avatar, pending or stored.
  # @rbs () -> untyped
  def avatar_upload_io
    pending_avatar_upload_io || StringIO.new(avatar.blob.download)
  end

  # Returns a readable stream of an avatar that is attached but not yet saved.
  # @rbs () -> untyped
  def pending_avatar_upload_io
    attachable = attachment_changes["avatar"]&.attachable

    return attachable[:io] if attachable.is_a?(Hash)
    return attachable.open if attachable.respond_to?(:open) && !attachable.is_a?(ActiveStorage::Blob)

    attachable if attachable.respond_to?(:read)
  end

  # Validates that the avatar is not larger than the maximum size.
  # @rbs () -> void
  def validate_avatar_size
    return if avatar.blob.byte_size <= MAX_AVATAR_SIZE

    errors.add(:avatar, :file_size_too_large)
  end

    # Creates a child profile after a child user is saved.
    # @rbs () -> void
    def provision_child_profile
      return unless child?

      ensure_child_profile
    end
end
