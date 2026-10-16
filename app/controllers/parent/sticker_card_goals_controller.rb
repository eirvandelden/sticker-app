# Groups the controllers that parents use.
module Parent
  # Lets parents set the reward goal of a child's active card.
  class StickerCardGoalsController < ApplicationController
    before_action :ensure_parent
    before_action :set_child

    # Overrides the reward goal on the child's active card.
    # @rbs () -> void
    def update
      @child.active_sticker_card.override_goal!(sticker_card_params[:goal])

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to parent_children_path, notice: t("flash.parent.sticker_card_goals.updated") }
      end
    end

    private

    # Loads the child profile from the request.
    # @rbs () -> void
    def set_child
      @child = ChildProfile.find(params[:child_id])
    end

    # Permits only the goal.
    # @rbs () -> ActionController::Parameters
    def sticker_card_params
      params.expect(sticker_card: [ :goal ])
    end
  end
end
