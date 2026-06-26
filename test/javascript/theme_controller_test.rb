require "test_helper"

class ThemeControllerTest < ActiveSupport::TestCase
  test "theme controller uses plain methods without live listeners" do
    source = Rails.root.join("app/javascript/controllers/theme_controller.js").read

    assert_no_match(/^\s+#\w/, source)
    assert_no_match(/addEventListener\("change"/, source)
    assert_no_match(/removeEventListener\("change"/, source)
  end
end
