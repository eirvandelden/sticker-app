# Groups the controllers that administrators use.
module Admin
  # Lets administrators manage user accounts.
  class UsersController < Admin::BaseController
    # @type const Current: untyped
    before_action :set_user, only: [ :show, :edit, :update, :destroy ]

    # Lists all users, newest first.
    # @rbs () -> void
    def index
      @users = User.all.order(created_at: :desc)
    end

    # Shows one user.
    # @rbs () -> void
    def show
    end

    # Builds a blank user for the form.
    # @rbs () -> void
    def new
      @user = User.new
    end

    # Creates a user with the chosen role.
    # @rbs () -> void
    def create
      @user = User.new(user_params)
      assign_role(@user)

      if @user.save
        redirect_to admin_user_path(@user), notice: t(".success")
      else
        render :new, status: :unprocessable_entity
      end
    end

    # Shows the form to edit a user.
    # @rbs () -> void
    def edit
    end

    # Updates a user and the chosen role.
    # @rbs () -> void
    def update
      @user.assign_attributes(user_params)
      assign_role(@user)

      if @user.save
        redirect_to admin_user_path(@user), notice: t(".success")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # Deletes a user, except the signed-in administrator.
    # @rbs () -> void
    def destroy
      if @user == Current.user
        redirect_to admin_users_path, alert: t(".cannot_delete_self")
      else
        @user.destroy
        redirect_to admin_users_path, notice: t(".success")
      end
    end

    private

    # Loads the user from the request.
    # @rbs () -> void
    def set_user
      @user = User.find(params[:id])
    end

    # Permits the user fields an administrator may set.
    # @rbs () -> ActionController::Parameters
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :locale, :name, :avatar)
    end

    # Sets the requested role when it is a known role.
    # @rbs (User user) -> void
    def assign_role(user)
      role = params.dig(:user, :role).to_s
      return if role.blank?
      return unless User.roles.key?(role)

      user.role = role
    end
  end
end
