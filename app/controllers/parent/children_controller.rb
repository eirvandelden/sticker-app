module Parent
  class ChildrenController < ApplicationController
    before_action :ensure_parent
    before_action :set_child, only: [ :edit, :update ]

    def index
      @children = ChildProfile.includes(:sticker_cards, { allowances: :allowance_periods }, user: { avatar_attachment: :blob })
    end

    def edit
    end

    def update
      if @child.user.update(child_user_params)
        redirect_to edit_parent_child_path(@child), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_child
      @child = ChildProfile.includes(:user).find(params[:id])
    end

    def child_user_params
      params.require(:user).permit(:name)
    end
  end
end
