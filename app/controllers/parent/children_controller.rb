module Parent
  class ChildrenController < ApplicationController
    before_action :ensure_parent
    before_action :set_open_cards_count, only: :index

    def index
      @children = ChildProfile.includes(:user, :sticker_cards)
    end

    private

    def set_open_cards_count
      @open_cards_count = StickerCard.open.count
    end
  end
end
