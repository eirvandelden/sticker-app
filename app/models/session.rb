# Represents a signed-in browser session of a user.
class Session < ApplicationRecord
  include Appkit::SessionBehavior

  belongs_to :user
end
