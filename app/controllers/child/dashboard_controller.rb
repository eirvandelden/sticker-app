module Child
  class DashboardController < ApplicationController
    before_action :ensure_child

    def show
      @child_profile = Current.user.child_profile
      return redirect_to root_path, alert: t("errors.child_profile_required") unless @child_profile

      @card = @child_profile.sticker_cards.order(created_at: :desc).first
      @last_viewed = session[:last_card_viewed_at]
      session[:last_card_viewed_at] = Time.current
      @recent_stickers = recent_stickers_since_last_visit
      @completed_card_ids = @child_profile.sticker_cards.select(&:rewardable?).map(&:id)
    end

    private

    def recent_stickers_since_last_visit
      return [] unless @last_viewed && @card

      @card.stickers.where("created_at > ?", @last_viewed).order(created_at: :asc)
    end
  end
end
