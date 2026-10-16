# Groups the controllers that parents use.
module Parent
  # Lets parents see and edit their children.
  class ChildrenController < ApplicationController
    before_action :ensure_parent
    before_action :set_child, only: [ :show, :edit, :update ]

    # Loads every child with their cards, allowances and avatar.
    # @rbs () -> void
    def index
      @children = ChildProfile.includes(:sticker_cards, { allowances: :allowance_periods },
user: { avatar_attachment: :blob })
    end

    # Shows one child.
    # @rbs () -> void
    def show
    end

    # Shows the form to edit a child.
    # @rbs () -> void
    def edit
    end

    # Saves the child's name.
    # @rbs () -> void
    def update
      if @child.user.update(child_user_params)
        redirect_to edit_parent_child_path(@child), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    # Loads the child profile and its user from the request.
    # @rbs () -> void
    def set_child
      @child = ChildProfile.includes(:user).find(params[:id])
    end

    # Permits only the child's name.
    # @rbs () -> ActionController::Parameters
    def child_user_params
      params.require(:user).permit(:name)
    end
  end
end
