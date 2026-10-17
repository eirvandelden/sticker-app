# Represents a signed-in browser session of a user.
class Session < ApplicationRecord
  # @rbs skip
  include Appkit::SessionBehavior

  belongs_to :user
end
