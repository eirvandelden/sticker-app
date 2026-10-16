# Is the base class of the admin controllers and lets only administrators in.
class Admin::BaseController < ApplicationController
  before_action :ensure_admin
end
