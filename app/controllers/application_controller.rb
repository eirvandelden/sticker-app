class ApplicationController < ActionController::Base
  include Appkit::Authentication, Authorization, VersionHeaders

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  layout :resolve_layout

  private

  def resolve_layout
    return "login" unless Current.user
    Current.user.child? ? "child" : "parent"
  end

  def set_locale
    I18n.locale = Current.user&.locale || I18n.default_locale
  end

  # Appkit::SessionsController/TransfersController redirect here after auth;
  # preserve Sticker App's role-based landing page instead of the engine's
  # default (return_to_after_authenticating || root_url).
  def post_authenticating_url
    after_login_path_for(Current.user)
  end

  # Appkit sends already-signed-in visitors of the login page back to root_url,
  # but root_url *is* the login page here, so that bounces forever.
  def redirect_signed_in_user_to_root
    redirect_to after_login_path_for(Current.user) if signed_in?
  end

  def after_login_path_for(user)
    return child_dashboard_path if user.child?

    parent_children_path
  end
end
