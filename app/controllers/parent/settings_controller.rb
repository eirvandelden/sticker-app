module Parent
  class SettingsController < ApplicationController
    before_action :ensure_parent

    def index
      @children = ChildProfile.includes(:user)
    end
  end
end
