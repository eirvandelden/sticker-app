# Gives controllers the filters that restrict an action to administrators, parents or children.
# @rbs module-self: ActionController::Base
module Authorization
  extend ActiveSupport::Concern

  private

  # Redirects to the root unless the current user is an administrator.
  # @rbs () -> void
  def ensure_admin
    redirect_to root_path, alert: t("errors.admin_required") unless Current.user&.admin?
  end

  # Redirects to the root unless the current user is a parent or an administrator.
  # @rbs () -> void
  def ensure_parent
    redirect_to root_path, alert: t("errors.parent_required") unless Current.user&.parent? || Current.user&.admin?
  end

  # Redirects to the root unless the current user is a child.
  # @rbs () -> void
  def ensure_child
    redirect_to root_path, alert: t("errors.child_required") unless Current.user&.child?
  end
end
