# Loads the active user named in the request for the controller's actions.
# @rbs module-self: ActionController::Base
module UserScoped
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ActionController::Base)
    before_action :set_user
  end

  private
    # Loads the active user from the request.
    # @rbs () -> void
    def set_user
      @user = User.active.find(params[:user_id])
    end
end
