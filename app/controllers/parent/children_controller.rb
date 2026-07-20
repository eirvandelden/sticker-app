module Parent
  class ChildrenController < ApplicationController
    before_action :ensure_parent
    before_action :set_child, only: [ :edit, :update ]
    before_action :set_open_cards_count, only: :index

    def index
      @children = ChildProfile.includes(:sticker_cards, user: { avatar_attachment: :blob })
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

    def set_open_cards_count
      @open_cards_count = StickerCard.open.count
    end

    def child_user_params
      params.require(:user).permit(:name)
    end
  end
end
