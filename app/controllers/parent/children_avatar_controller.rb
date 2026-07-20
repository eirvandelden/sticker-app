module Parent
  class ChildrenAvatarController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    def update
      if @child.user.update(avatar_params)
        redirect_to edit_parent_child_path(@child), notice: t(".success")
      else
        render "parent/children/edit", status: :unprocessable_entity
      end
    end

    private

    def set_child
      @child = ChildProfile.includes(:user).find(params[:child_id])
    end

    def avatar_params
      params.require(:user).permit(:avatar)
    end
  end
end
