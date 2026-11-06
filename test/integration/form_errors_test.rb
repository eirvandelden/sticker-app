require "test_helper"

class FormErrorsTest < ActionDispatch::IntegrationTest
  setup do
    @parent = users(:parent)
    @child = child_profiles(:one)
  end

  test "child name form shows one counted alert" do
    sign_in_as @parent

    patch parent_child_path(@child), params: { user: { name: "" } }

    assert_counted_alert 1
    assert_select "form[action=?] aside[role=alert]", parent_child_path(@child), count: 1
  end

  test "child avatar form shows one counted alert" do
    sign_in_as @parent

    patch parent_child_avatar_path(@child),
params: { user: { avatar: fixture_file_upload("avatar.txt", "text/plain") } }

    assert_counted_alert 1
    assert_select "form[action=?] aside[role=alert]", parent_child_avatar_path(@child), count: 1
  end

  test "child goals form shows one counted alert" do
    sign_in_as @parent

    patch parent_child_child_profile_path(@child), params: { child_profile: { sticker_goal: 0 } }

    assert_counted_alert 1
    assert_select "form[action=?] aside[role=alert]", parent_child_child_profile_path(@child), count: 1
  end

  test "allowance create form shows one counted alert" do
    sign_in_as @parent
    child = child_profiles(:two)

    post parent_child_allowances_path(child),
         params: { allowance: { kind: "zakgeld", amount_cents: 0, frequency: "weekly", due_day: 1 } }

    assert_counted_alert 1
    assert_select "form[action=?] aside[role=alert]", parent_child_allowances_path(child), count: 1
  end

  test "allowance update form shows one counted alert" do
    sign_in_as @parent
    allowance = allowances(:zakgeld_one)

    patch parent_child_allowance_path(@child, allowance), params: { allowance: { amount_cents: 0 } }

    assert_counted_alert 1
    assert_select "form[action=?] aside[role=alert]", parent_child_allowance_path(@child, allowance), count: 1
  end

  test "allowance without a kind shows one counted alert above the sections" do
    sign_in_as @parent
    child = child_profiles(:two)

    post parent_child_allowances_path(child),
         params: { allowance: { amount_cents: 500, frequency: "weekly", due_day: 1 } }

    assert_select "main > article > aside[role=alert]", count: 1
    assert_select "main > article > aside[role=alert] > h2", text: /error/
  end

  test "admin user form shows one counted alert" do
    sign_in_as users(:admin)

    post admin_users_path, params: { user: { name: "", email: "new@example.com", role: "child",
                                             password: "a", password_confirmation: "b" } }

    assert_response :unprocessable_entity
    assert_select "form aside[role=alert]", count: 1
    assert_select "form aside[role=alert] > h2",
                  text: I18n.t("errors.template.header", count: css_select("form aside[role=alert] li").size)
  end

  test "profile form shows one counted alert" do
    sign_in_as @parent

    patch user_profile_path(@parent), params: { user: { name: "" } }

    assert_counted_alert 1
    assert_select "form aside[role=alert]", count: 1
  end

  test "renders nothing without errors" do
    sign_in_as @parent

    get edit_parent_child_path(@child)

    assert_select "aside[role=alert]", count: 0
  end

  test "counts the errors in its h2" do
    sign_in_as @parent

    patch parent_child_child_profile_path(@child), params: { child_profile: { sticker_goal: 0 } }

    assert_select "aside[role=alert] > h2", text: "1 error prevented this record from being saved"
    assert_select "aside[role=alert] > ul > li", count: 1
  end

  private

  def assert_counted_alert(count)
    assert_response :unprocessable_entity
    assert_select "aside[role=alert] > h2", text: I18n.t("errors.template.header", count: count)
  end
end
