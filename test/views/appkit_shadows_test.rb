require "test_helper"

class AppkitShadowsTest < ActiveSupport::TestCase
  test "the login view carries appkit's markup" do
    assert_equal appkit_lines("sessions/new.html.erb"), app_lines("sessions/new.html.erb")
  end

  private

  def appkit_lines(path)
    view_lines Appkit::Engine.root.join("app/views/appkit", path)
  end

  def app_lines(path)
    view_lines Rails.root.join("app/views/appkit", path)
  end

  def view_lines(file)
    File.readlines(file, chomp: true).grep_v(/\A\s*<%#/)
  end
end
