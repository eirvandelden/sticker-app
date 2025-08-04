module Parent
  class PenaltiesController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_parent!

    def create
      child = ChildProfile.find(params[:child_id])
      card = child.sticker_cards.order(created_at: :desc).first

      card.stickers.create!(
        kind: :negative,
        giver: Current.user,
        note: params[:note].presence
      )

      redirect_to parent_children_path, notice: t("flash.parent.penalties.created")
    end

    private

    def ensure_parent!
      redirect_to root_path, alert: "Access denied" unless Current.user.parent?
    end
  end
end
