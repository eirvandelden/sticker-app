class SessionsController < ApplicationController
  allow_unauthenticated_access only: [ :new, :create ]

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.strip&.downcase)
    if user&.authenticate(params[:password])
      start_new_session_for(user)
      redirect_to after_login_path_for(user)
    else
      flash.now[:alert] = t("flash.sessions.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: t("flash.sessions.logged_out")
  end

  private

  def after_login_path_for(user)
    user.parent? ? parent_children_path : child_dashboard_path
  end
end
