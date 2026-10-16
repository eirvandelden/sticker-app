# @rbs module-self: ActionController::Base
module Authorization
  private
    # @rbs () -> void
    def ensure_can_administer
      head :forbidden unless Current.user.can_administer?
    end

    # @rbs () -> void
    def ensure_current_user
      head :forbidden unless @user.current?
    end
end
