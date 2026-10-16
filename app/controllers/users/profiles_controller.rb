class Users::ProfilesController < ApplicationController
  include UserScoped

  before_action :ensure_profile_viewer, only: :show
  before_action :ensure_current_user, only: %i[ edit update ]

  # @rbs () -> void
  def show
  end

  # @rbs () -> void
  def edit
  end

  # @rbs () -> void
  def update
    if @user.update(user_params)
      redirect_to user_profile_path(@user), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # @rbs () -> void
  def ensure_profile_viewer
    redirect_to root_path if Current.user.child? && !@user.current?
  end

  # @rbs () -> void
  def ensure_current_user
    redirect_to root_path unless @user.current?
  end

  # @rbs () -> ActionController::Parameters
  def user_params
    return params.require(:user).permit(:avatar) if Current.user.child?

    params.require(:user).permit(:name, :email, :password, :avatar)
  end
end
