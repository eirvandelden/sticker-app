require "test_helper"

class ChildDashboardI18nTest < ActionDispatch::IntegrationTest
  test "gave_you key is present in all supported locales" do
    %i[en nl it].each do |locale|
      assert I18n.exists?("child.dashboard.gave_you", locale: locale),
             "child.dashboard.gave_you is missing in #{locale}"
    end
  end
end
