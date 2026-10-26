# Groups the controllers that parents use.
module Parent
  # Lets parents give a child a penalty.
  class PenaltiesController < ApplicationController
    # @type const Current: untyped
    before_action :ensure_parent

    # Adds a penalty to the child's newest card.
    # @rbs () -> void
    def create
      child = ChildProfile.find(params[:child_id])
      # @type var card: untyped
      card = child.sticker_cards.order(created_at: :desc).first

      card.stickers.create!(
        kind: :negative,
        giver: Current.user,
        note: params[:note].presence
      )

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to parent_children_path, notice: t("flash.parent.penalties.created") }
      end
    end
  end
end
