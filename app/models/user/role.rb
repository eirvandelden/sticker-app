# @rbs module-self: ApplicationRecord
module User::Role
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ApplicationRecord)
    enum :role, %i[ member administrator ], default: :member
  end

  # @rbs () -> bool
  def can_administer?
    administrator?
  end
end
