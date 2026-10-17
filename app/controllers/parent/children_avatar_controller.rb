# Groups the controllers that parents use.
module Parent
  # Lets parents change a child's avatar.
  class ChildrenAvatarController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    # Saves the child's new avatar.
    # @rbs () -> void
    def update
      if @child.user.update(avatar_params)
        redirect_to edit_parent_child_path(@child), notice: t(".success")
      else
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    private

    # Loads the child profile and its user from the request.
    # @rbs () -> void
    def set_child
      @child = ChildProfile.includes(:user).find(params[:child_id])
    end

    # Permits only the avatar.
    # @rbs () -> ActionController::Parameters
    def avatar_params
      params.require(:user).permit(:avatar)
    end
  end
end
