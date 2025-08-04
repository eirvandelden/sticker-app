module Child
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_child!

    def show
      @child_profile = Current.user.child_profile
      @card = @child_profile.sticker_cards.order(created_at: :desc).first
      @completed_count = @child_profile.sticker_cards.where(reward_given: true).count

      @last_viewed = session[:last_card_viewed_at]
      session[:last_card_viewed_at] = Time.current

      @recent_stickers = if @last_viewed
        @card.stickers.where("created_at > ?", @last_viewed).order(created_at: :asc)
      else
        []
      end
    end

    private

    def ensure_child!
      redirect_to root_path, alert: "Access denied" unless Current.user.child?
    end
  end
end
