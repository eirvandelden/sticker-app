# Holds the signed-in user and session for the current request.
class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session

  # Returns the current user's child profile, or nil for a user who is not a child.
  # @rbs () -> ChildProfile?
  def child_profile
    # @type var current: untyped
    current = self
    current.user&.child? ? current.user.child_profile : nil
  end
end
