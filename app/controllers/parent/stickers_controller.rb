module Parent
  class StickersController < ApplicationController
    before_action :ensure_parent

    def create
      child = ChildProfile.find(params[:child_id])
      card = child.sticker_cards.order(created_at: :desc).first

      emoji = params[:emoji_mode] == "choose" ? params[:emoji] : nil

      card.stickers.create!(
        kind: :positive,
        emoji: emoji.presence,
        giver: Current.user,
        note: params[:note].presence
      )

      redirect_to parent_children_path, notice: t("flash.parent.stickers.created")
    end

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
