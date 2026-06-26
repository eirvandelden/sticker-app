class PreferencesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(preferences_params)
      set_locale
      redirect_to edit_preferences_path, notice: t("flash.preferences.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def preferences_params
    permitted = params.require(:user).permit(
      :email, :password, :password_confirmation,
      :locale, :color_scheme, :light_theme, :dark_theme
    )
    permitted[:password].blank? ? permitted.except(:password, :password_confirmation) : permitted
  end
end
