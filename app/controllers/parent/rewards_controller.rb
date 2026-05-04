module Parent
  class RewardsController < ApplicationController
    before_action :ensure_parent

    def create
      child = ChildProfile.find(params[:child_id])
      card = child.sticker_cards.where.not(completed_at: nil).where(reward_given: [ nil, false ]).order(completed_at: :asc).first

      if card && card.update(reward_given: true)
        redirect_to parent_children_path, notice: t("flash.parent.rewards.success")
      else
        redirect_to parent_children_path, alert: t("flash.parent.rewards.failure")
      end
    end
  end
end
