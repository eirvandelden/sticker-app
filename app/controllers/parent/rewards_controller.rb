module Parent
  class RewardsController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_parent!

    def create
      child = ChildProfile.find(params[:child_id])
      card = child.sticker_cards.order(created_at: :desc).first

      if card.update(reward_given: true)
        redirect_to parent_children_path, notice: t("flash.parent.rewards.success")
      else
        redirect_to parent_children_path, alert: t("flash.parent.rewards.failure")
      end
    end

    private

    def ensure_parent!
      redirect_to root_path, alert: "Access denied" unless Current.user.parent?
    end
  end
end
