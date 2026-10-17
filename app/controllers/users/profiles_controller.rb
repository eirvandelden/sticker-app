# Shows and edits a user's profile.
class Users::ProfilesController < ApplicationController
  include UserScoped

  before_action :ensure_profile_viewer, only: :show
  before_action :ensure_current_user, only: %i[ edit update ]

  # Shows the user's profile.
  # @rbs () -> void
  def show
  end

  # Shows the form to edit the profile.
  # @rbs () -> void
  def edit
  end

  # Saves the profile changes.
  # @rbs () -> void
  def update
    if @user.update(user_params)
      redirect_to user_profile_path(@user), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  # Keeps a child from viewing another user's profile.
  # @rbs () -> void
  def ensure_profile_viewer
    redirect_to root_path if Current.user.child? && !@user.current?
  end

  # Redirects to the root unless the profile is the signed-in user's own.
  # @rbs () -> void
  def ensure_current_user
    redirect_to root_path unless @user.current?
  end

  # Permits the profile fields, and only the avatar for a child.
  # @rbs () -> ActionController::Parameters
  def user_params
    return params.require(:user).permit(:avatar) if Current.user.child?

    params.require(:user).permit(:name, :email, :password, :avatar)
  end
end
