require "application_system_test_case"

class ConfirmDialogTest < ApplicationSystemTestCase
  test "a page without the shared dialog falls back to the browser confirm" do
    visit new_session_path

    assert_no_selector "dialog#confirm-dialog", visible: :all
    accept_confirm("Sure?") { page.execute_script("Turbo.config.forms.confirm('Sure?')") }
  end
end
