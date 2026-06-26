class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { render_rejection :too_many_requests }

  def new
  end

  def create
    if user = User.active.authenticate_by(email: params[:email], password: params[:password])
      start_new_session_for user
      redirect_to post_authenticating_url
    else
      render_rejection :unauthorized
    end
  end

  def destroy
    terminate_session

    redirect_to root_path, notice: t("flash.sessions.logged_out")
  end

  private
    def render_rejection(status)
      message = status == :too_many_requests ? t("flash.sessions.too_many_requests") : t("flash.sessions.unauthorized")

      if status == :too_many_requests
        flash.now[:alert] = message
        render :new, status: status
      else
        flash[:alert] = message
        redirect_to new_session_path
      end
    end
end
