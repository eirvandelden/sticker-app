class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_user

  def set_current_user
    Current.user = User.find_by(id: session[:user_id])
  end

  def authenticate_user!
    redirect_to new_session_path, alert: "Please log in" unless Current.user
  end
end
