module Parent
  class ChildProfilesController < ApplicationController
    before_action :ensure_parent
    before_action :set_child_profile

    def update
      if @child_profile.update(child_profile_params)
        redirect_to edit_parent_child_path(@child_profile), notice: t("flash.parent.child_profiles.updated")
      else
        @child = @child_profile
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    private

    def set_child_profile
      @child_profile = ChildProfile.includes(:user).find(params[:child_id])
    end

    def child_profile_params
      params.expect(child_profile: [ :sticker_goal ])
    end
  end
end
