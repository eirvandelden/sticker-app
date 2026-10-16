class Current < ActiveSupport::CurrentAttributes
  attribute :user, :session

  def child_profile
    user&.child? ? user.child_profile : nil
  end
end
