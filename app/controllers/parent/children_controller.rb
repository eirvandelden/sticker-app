module Parent
  class ChildrenController < ApplicationController
    before_action :authenticate_user!
    before_action :ensure_parent!

    def index
      @children = ChildProfile.includes(:user, :sticker_cards)
    end

    private

    def ensure_parent!
      redirect_to root_path, alert: "Access denied" unless Current.user.parent?
    end
  end
end
