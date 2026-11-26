require "test_helper"

class OriginFlowTest < ActionDispatch::IntegrationTest
  setup do
    @child = child_profiles(:one)
    @settings_origin = "settings.child_settings"
  end

  test "Instellingen, child edit, save keeps the back link to Instellingen" do
    sign_in_as users(:parent)
    get parent_settings_path
    edit_link = css_select("main a[href^='#{edit_parent_child_path(@child)}']").first["href"]

    get edit_link

    assert_select "form input[name=from][value=?]", @settings_origin, minimum: 5
    patch parent_child_path(@child), params: { user: { name: "Renamed" }, from: @settings_origin }

    assert_redirected_to "#{edit_parent_child_path(@child)}?from=#{@settings_origin}"
    follow_redirect!

    assert_back_link "Child settings", "#{parent_settings_path}?from=#{@settings_origin}"
  end

  test "a failed save on child edit keeps the origin" do
    sign_in_as users(:parent)

    patch parent_child_path(@child), params: { user: { name: "" }, from: @settings_origin }

    assert_response :unprocessable_entity
    assert_select "form input[name=from][value=?]", @settings_origin, minimum: 5
    assert_back_link "Child settings", "#{parent_settings_path}?from=#{@settings_origin}"
  end

  test "turning off an allowance keeps the origin" do
    sign_in_as users(:parent)
    allowance = allowances(:zakgeld_one)
    get "#{edit_parent_child_path(@child)}?from=#{@settings_origin}"

    assert_select "form[action=?] input[name=from][value=?]", parent_child_allowance_path(@child, allowance),
      @settings_origin
    delete parent_child_allowance_path(@child, allowance), params: { from: @settings_origin }

    assert_redirected_to "#{edit_parent_child_path(@child)}?from=#{@settings_origin}"
  end

  test "user list, user, edit, save keeps the back link to the list" do
    sign_in_as users(:admin)
    user = users(:parent)
    get admin_users_path
    show_link = css_select("main a[href^='#{admin_user_path(user)}?']").first["href"]
    get show_link
    edit_link = css_select("main > header a[href*='/edit']").first["href"]
    get edit_link

    assert_select "form input[name=from][value=?]", "admin.users"
    patch admin_user_path(user), params: { user: { name: "Renamed" }, from: "admin.users" }

    assert_redirected_to "#{admin_user_path(user)}?from=admin.users"
    follow_redirect!

    assert_back_link "Users", "#{admin_users_path}?from=admin.users"
  end

  test "Account, Profiel, edit, save keeps the back link to Account" do
    sign_in_as users(:parent)
    get account_path
    get css_select("main a[href*='profile']").first["href"]
    get css_select("main > header a[href*='/edit']").first["href"]

    assert_select "form input[name=from][value=account]"
    patch user_profile_path(users(:parent)), params: { user: { name: "Renamed" }, from: "account" }

    assert_redirected_to "#{user_profile_path(users(:parent))}?from=account"
    follow_redirect!

    assert_back_link "Account", account_path
  end

  test "a failed nested save on child edit shows the back link and Cancel, with and without an origin" do
    sign_in_as users(:parent)
    child = child_profiles(:two)

    [ :child_profile, :avatar, :allowances ].each do |failure|
      { {} => parent_children_path, { from: @settings_origin } => parent_settings_path }.each do |extra, path|
        fail_nested_save(failure, child, extra)

        assert_response :unprocessable_entity, failure.to_s
        assert_select "main > header > nav > a:first-child[href=?]", path, message: "#{failure} #{extra}"
        assert_select "footer a[role=button][href=?]", path, minimum: 5, message: "#{failure} #{extra} cancel"
      end
    end
  end

  test "a form opened without an origin sends no from" do
    sign_in_as users(:parent)

    get edit_parent_child_path(@child)

    assert_select "input[name=from]", count: 0
  end

  private

  def fail_nested_save(failure, child, extra)
    case failure
    when :child_profile then fail_child_profile_save(child, extra)
    when :avatar then fail_avatar_save(child, extra)
    when :allowances then fail_allowances_save(child, extra)
    end
  end

  def fail_child_profile_save(child, extra)
    patch parent_child_child_profile_path(child), params: { child_profile: { sticker_goal: 0 } }.merge(extra)
  end

  def fail_avatar_save(child, extra)
    avatar = fixture_file_upload("avatar.txt", "text/plain")
    patch parent_child_avatar_path(child), params: { user: { avatar: avatar } }.merge(extra)
  end

  def fail_allowances_save(child, extra)
    allowance = { kind: "zakgeld", amount_cents: 0, frequency: "weekly", due_day: 1 }
    post parent_child_allowances_path(child), params: { allowance: allowance }.merge(extra)
  end

  def assert_back_link(label, path)
    assert_select "main > header > nav > a:first-child[href=?]", path, text: "‹ #{label}"
  end
end
