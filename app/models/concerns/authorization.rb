# Gives controllers the checks that guard administrator and own-user actions.
# @rbs module-self: ActionController::Base
module Authorization
  # @type const Current: untyped
  private
    # Responds with forbidden unless the current user can administer.
    # @rbs () -> void
    def ensure_can_administer
      head :forbidden unless Current.user.can_administer?
    end

    # Responds with forbidden unless the loaded user is the current user.
    # @rbs () -> void
    def ensure_current_user
      head :forbidden unless @user.current?
    end
end
