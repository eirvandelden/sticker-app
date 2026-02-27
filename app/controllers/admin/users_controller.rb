class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    assign_role(@user)

    if @user.save
      redirect_to admin_user_path(@user), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @user.assign_attributes(user_params)
    assign_role(@user)

    if @user.save
      redirect_to admin_user_path(@user), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: t(".cannot_delete_self")
    else
      @user.destroy
      redirect_to admin_users_path, notice: t(".success")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def assign_role(user)
    role = params.dig(:user, :role).to_s
    return if role.blank?
    return unless User.roles.key?(role)

    user.role = role
  end
end
