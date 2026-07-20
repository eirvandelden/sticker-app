require "test_helper"

class Parent::ChildrenNameTest < ActionDispatch::IntegrationTest
  setup do
    @parent     = users(:parent)
    @admin      = users(:admin)
    @child      = child_profiles(:one)
    @child_user = @child.user
  end

  test "parent can reach child settings page with name form" do
    sign_in_as @parent
    get edit_parent_child_path(@child)

    assert_response :success
    assert_select "h1", text: I18n.t("parent.child_profile.edit.title")
    assert_select "form[action='#{parent_child_path(@child)}'][method='post']" do
      assert_select "input[name='_method'][type='hidden'][value='patch']"
      assert_select "input[name='user[name]'][required]"
    end
  end

  test "parent can update child name" do
    sign_in_as @parent
    patch parent_child_path(@child), params: { user: { name: "Updated Name" } }

    assert_redirected_to edit_parent_child_path(@child)
    assert_equal "Updated Name", @child_user.reload.name
  end

  test "parent cannot set blank child name" do
    sign_in_as @parent
    patch parent_child_path(@child), params: { user: { name: "" } }

    assert_response :unprocessable_entity
  end

  test "admin can also update child name" do
    sign_in_as @admin
    patch parent_child_path(@child), params: { user: { name: "Admin Set Name" } }

    assert_redirected_to edit_parent_child_path(@child)
    assert_equal "Admin Set Name", @child_user.reload.name
  end

  test "child cannot reach parent edit page" do
    sign_in_as users(:user)
    get edit_parent_child_path(@child)

    assert_redirected_to root_path
  end

  test "child cannot update another child's name" do
    other_child = child_profiles(:two)
    sign_in_as users(:user)
    assert_no_changes -> { other_child.user.reload.name } do
      patch parent_child_path(other_child), params: { user: { name: "Updated Name" } }
    end

    assert_redirected_to root_path
  end
end
