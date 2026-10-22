# Represents a signed-in browser session of a user.
class Session < ApplicationRecord
  # @type const Appkit::SessionBehavior: untyped
  # @rbs skip
  include Appkit::SessionBehavior

  belongs_to :user
end
