# Groups the controllers that administrators use.
module Admin
  # Is the base class of the admin controllers and lets only administrators in.
  class BaseController < ApplicationController
    before_action :ensure_admin
  end
end
