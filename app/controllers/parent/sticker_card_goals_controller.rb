module Parent
  class StickerCardGoalsController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    def update
      @child.active_sticker_card.override_goal!(sticker_card_params[:goal])

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to parent_children_path, notice: t("flash.parent.sticker_card_goals.updated") }
      end
    end

    private

    def set_child
      @child = ChildProfile.find(params[:child_id])
    end

    def sticker_card_params
      params.expect(sticker_card: [ :goal ])
    end
  end
end
