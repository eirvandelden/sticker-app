# Groups the controllers that children use.
module Child
  # Shows a child their sticker card and progress.
  class DashboardController < ApplicationController
    before_action :ensure_child

    # Loads the child's active card, new stickers since the last visit and completed cards.
    # @rbs () -> void
    def show
      @child_profile = Current.user.ensure_child_profile

      @card = @child_profile.sticker_cards.order(created_at: :desc).first
      @last_viewed = session[:last_card_viewed_at]
      session[:last_card_viewed_at] = Time.current
      @recent_stickers = recent_stickers_since_last_visit
      @completed_card_ids = @child_profile.sticker_cards.filter_map { |card| card.id if card.rewardable? }
    end

    private

    # Returns the stickers given since the child last viewed the card.
    # @rbs () -> untyped
    def recent_stickers_since_last_visit
      return [] unless @last_viewed && @card

      @card.stickers.where("created_at > ?", @last_viewed).order(created_at: :asc)
    end
  end
end
