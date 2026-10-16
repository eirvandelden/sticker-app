module Parent
  class SettingsController < ApplicationController
    before_action :ensure_parent

    # @rbs () -> void
    def index
      @children = ChildProfile.includes(:user)
    end
  end
end
