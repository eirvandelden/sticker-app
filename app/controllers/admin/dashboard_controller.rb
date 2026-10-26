# Groups the controllers that administrators use.
module Admin
  # Shows the administrator overview of users.
  class DashboardController < Admin::BaseController
    # Loads the newest users and the user counts.
    # @rbs () -> void
    def index
      @users = User.all.order(created_at: :desc).limit(10)
      @total_users = User.count
      @admin_users = User.admin.count
    end
  end
end
