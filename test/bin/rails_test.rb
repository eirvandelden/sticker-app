# frozen_string_literal: true

require "test_helper"
require "open3"
require "rbconfig"

class RailsLauncherTest < ActiveSupport::TestCase
  test "runs Rails commands" do
    output, status = Open3.capture2e(RbConfig.ruby, Rails.root.join("bin/rails").to_s, "--version")

    assert_predicate status, :success?, output
    assert_equal "Rails #{Rails::VERSION::STRING}", output.strip
  end
end
