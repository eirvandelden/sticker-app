class ChildProfileChannel < ApplicationCable::Channel
  def subscribed
    child_profile = find_child_profile
    stream_for child_profile if child_profile
  end

  private

  def find_child_profile
    profile = ChildProfile.find_by(id: params[:child_profile_id])
    return nil unless profile
    # Authorize: user must be the child or a parent
    return profile if current_user.child? && current_user.child_profile == profile
    return profile if current_user.parent?
    nil
  end
end
