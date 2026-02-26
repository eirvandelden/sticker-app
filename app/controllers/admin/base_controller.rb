class Admin::BaseController < ApplicationController
  before_action :ensure_admin

  layout "admin"
end
