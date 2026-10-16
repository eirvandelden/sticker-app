# Groups the controllers that parents use.
module Parent
  # Lets parents change a child's goals and birthdate.
  class ChildProfilesController < ApplicationController
    before_action :ensure_parent
    before_action :set_child_profile

    # Saves the child's sticker goal, reward goal and birthdate.
    # @rbs () -> void
    def update
      if @child_profile.update(child_profile_params)
        redirect_to edit_parent_child_path(@child_profile), notice: t("flash.parent.child_profiles.updated")
      else
        @child = @child_profile
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    private

    # Loads the child profile and its user from the request.
    # @rbs () -> void
    def set_child_profile
      @child_profile = ChildProfile.includes(:user).find(params[:child_id])
    end

    # Permits the child profile fields a parent may set.
    # @rbs () -> ActionController::Parameters
    def child_profile_params
      params.expect(child_profile: [ :sticker_goal, :goal, :birthdate ])
    end
  end
end
