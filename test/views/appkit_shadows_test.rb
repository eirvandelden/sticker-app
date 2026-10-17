require "test_helper"

class AppkitShadowsTest < ActiveSupport::TestCase
  test "the login view carries appkit's markup" do
    assert_equal appkit_lines("sessions/new.html.erb"), app_lines("sessions/new.html.erb")
  end

  test "the nav differs from appkit's only in the Home link" do
    app_nav = app_lines("shared/_nav.html.erb")
    appkit_nav = appkit_lines("shared/_nav.html.erb")
    home = app_nav.index { |line| line.strip == APP_HOME_LINE }

    assert home, "the app's nav has no Home line"
    assert_includes appkit_nav[home], "root_path"
    assert_equal without_line(appkit_nav, home), without_line(app_nav, home)
  end

  private

  APP_HOME_LINE = %(<li><%= nav_section_tab t("appkit.navigation.home"), home_path %></li>)

  def without_line(lines, index)
    lines.reject.with_index { |_line, position| position == index }
  end

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
