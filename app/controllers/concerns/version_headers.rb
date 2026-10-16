# @rbs module-self: ActionController::Base
module VersionHeaders
  extend ActiveSupport::Concern

  included do
    # @type self: singleton(ActionController::Base)
    before_action :set_version_headers
  end

  private
    # @rbs () -> void
    def set_version_headers
      response.headers["X-Rev"]     = Rails.application.config.git_revision
      response.headers["X-Version"] = Rails.application.config.app_version
    end
end
