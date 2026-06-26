class Users::ProfilesController < ApplicationController
  include UserScoped

  before_action :ensure_current_user, only: %i[ show edit update ]

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to user_profile_path(@user), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def ensure_current_user
    redirect_to root_path unless @user.current?
  end

  def user_params
    return params.require(:user).permit(:avatar) if Current.user.child?

    params.require(:user).permit(:name, :email, :password, :avatar)
  end
end
