# Groups the controllers that parents use.
module Parent
  # Shows parents the settings page for their children.
  class SettingsController < ApplicationController
    before_action :ensure_parent

    # Loads every child with their user.
    # @rbs () -> void
    def index
      @children = ChildProfile.includes(:user)
    end
  end
end
