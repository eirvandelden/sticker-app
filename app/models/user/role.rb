# Adds the administrator role to a user and answers whether the user can administer.
# @rbs module-self: ApplicationRecord
module User::Role
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ApplicationRecord)
    enum :role, %i[ member administrator ], default: :member
  end

  # Tells whether the user is an administrator.
  # @rbs () -> bool
  def can_administer?
    administrator?
  end
end
