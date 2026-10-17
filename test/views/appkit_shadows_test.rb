require "test_helper"

class AppkitShadowsTest < ActiveSupport::TestCase
  test "the login view carries appkit's markup" do
    assert_equal appkit_lines("sessions/new.html.erb"), app_lines("sessions/new.html.erb")
  end

  test "the nav differs from appkit's only in the Home link" do
    appkit_only = appkit_lines("shared/_nav.html.erb") - app_lines("shared/_nav.html.erb")
    app_only = app_lines("shared/_nav.html.erb") - appkit_lines("shared/_nav.html.erb")

    assert_equal [ %(<li><%= nav_section_tab t("appkit.navigation.home"), home_path %></li>) ], app_only.map(&:strip)
    assert_equal 1, appkit_only.size
    assert_includes appkit_only.first, "root_path"
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
