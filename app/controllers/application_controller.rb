# Is the base class of the controllers and sets locale, layout and role-based access.
class ApplicationController < ActionController::Base
  # @type const Current: untyped
  include VersionHeaders
  include Authorization
  # @rbs skip
  include Appkit::Authentication

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_locale

  layout :resolve_layout

  private

  # Picks the login, child or parent layout for the signed-in user.
  # @rbs () -> String
  def resolve_layout
    return "login" unless Current.user
    Current.user.child? ? "child" : "parent"
  end

  # Uses the signed-in user's locale, or the default locale.
  # @rbs () -> void
  def set_locale
    I18n.locale = Current.user&.locale || I18n.default_locale
  end

  # Returns the landing page for the user who just signed in.
  # Appkit::SessionsController/TransfersController redirect here after auth;
  # preserve Sticker App's role-based landing page instead of the engine's
  # default (return_to_after_authenticating || root_url).
  # @rbs () -> String
  def post_authenticating_url
    after_login_path_for(Current.user)
  end

  # Sends a signed-in visitor of the login page to their landing page.
  # Appkit sends already-signed-in visitors of the login page back to root_url,
  # but root_url *is* the login page here, so that bounces forever.
  # @rbs () -> void
  def redirect_signed_in_user_to_root
    redirect_to after_login_path_for(Current.user) if method(:signed_in?).call
  end

  # Returns the child dashboard for a child, and the children overview for everyone else.
  # @rbs (User user) -> String
  def after_login_path_for(user)
    return child_dashboard_path if user.child?

    parent_children_path
  end
end
