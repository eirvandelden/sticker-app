# Groups the controllers that parents use.
module Parent
  # Lets parents award stickers and see the sticker history.
  class StickersController < ApplicationController
    before_action :ensure_parent

    # Awards a positive sticker to the child's newest card.
    # @rbs () -> void
    def create
      child = ChildProfile.find(params[:child_id])
      # @type var card: untyped
      card = child.sticker_cards.order(created_at: :desc).first

      emoji = params[:emoji_mode] == "choose" ? params[:emoji] : nil

      card.stickers.create!(
        kind: :positive,
        emoji: emoji.presence,
        giver: Current.user,
        note: params[:note].presence
      )

      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html { redirect_to parent_children_path, notice: t("flash.parent.stickers.created") }
      end
    end

    # Lists the child's latest 100 stickers, grouped by date.
    # @rbs () -> void
    def index
      @child = ChildProfile.find(params[:child_id])
      @stickers = @child.sticker_cards
                        .includes(:stickers)
                        .flat_map(&:stickers)
                        .sort_by(&:created_at)
                        .reverse
                        .take(100)
      @stickers_by_date = @stickers.group_by { |s| s.created_at.to_date }
    end
  end
end
