module Authorization
  extend ActiveSupport::Concern

  private

  def ensure_admin
    redirect_to root_path, alert: t("errors.admin_required") unless Current.user&.admin?
  end

  def ensure_parent
    redirect_to root_path, alert: t("errors.parent_required") unless Current.user&.parent?
  end

  def ensure_child
    redirect_to root_path, alert: t("errors.child_required") unless Current.user&.child?
  end
end
