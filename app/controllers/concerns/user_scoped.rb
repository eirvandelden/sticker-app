# @rbs module-self: ActionController::Base
module UserScoped
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ActionController::Base)
    before_action :set_user
  end

  private
    # @rbs () -> void
    def set_user
      @user = User.active.find(params[:user_id])
    end
end
