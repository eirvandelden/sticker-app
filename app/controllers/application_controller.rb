class ApplicationController < ActionController::Base
  include Authentication, Authorization, VersionHeaders

  # Disable origin-checking CSRF mitigation
  skip_before_action :verify_authenticity_token

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  include Authentication
  include Authorization

  layout :resolve_layout

  before_action :require_authentication

  private

  def resolve_layout
    return "signin" unless Current.user
    Current.user.child? ? "child" : "parent"
  end
end
