class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id

      if user.child?
        request.session_options[:expire_after] = 1.year
      end

      redirect_to after_login_path_for(user)
    else
      flash.now[:alert] = t("flash.sessions.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t("flash.sessions.logged_out")
  end

  private

  def after_login_path_for(user)
    user.parent? ? parent_children_path : child_dashboard_path
  end
end
