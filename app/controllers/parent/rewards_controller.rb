module Parent
  class RewardsController < ApplicationController
    before_action :ensure_parent

    def create
      child = ChildProfile.find(params[:child_id])
      card = child.rewardable_sticker_card

      if card && card.update(reward_given: true)
        respond_to do |format|
          format.turbo_stream { head :ok }
          format.html { redirect_to parent_children_path, notice: t("flash.parent.rewards.success") }
        end
      else
        respond_to do |format|
          format.turbo_stream { head :unprocessable_entity }
          format.html { redirect_to parent_children_path, alert: t("flash.parent.rewards.failure") }
        end
      end
    end
  end
end
