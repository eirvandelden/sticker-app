require "test_helper"

class Parent::ChildProfilesTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @admin   = users(:admin)
    @child   = users(:user)
    @profile = child_profiles(:one)
  end

  test "parent can view child settings page with sticker goal form" do
    sign_in_as @parent
    get edit_parent_child_path(@profile)

    assert_response :success
    assert_select "h1", text: I18n.t("parent.child_profile.edit.title")
    assert_select "form[action='#{parent_child_child_profile_path(@profile)}'][method='post']" do
      assert_select "input[name='_method'][type='hidden'][value='patch']"
      assert_select "input[name='child_profile[sticker_goal]'][type='number'][required]"
    end
  end

  test "parent can update sticker_goal" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 5 } }

    assert_redirected_to edit_parent_child_path(@profile)
    assert_equal 5, @profile.reload.sticker_goal
  end

  test "invalid sticker_goal is rejected" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 0 } }

    assert_response :unprocessable_entity
  end

  test "child cannot access child settings page" do
    sign_in_as @child
    get edit_parent_child_path(@profile)

    assert_redirected_to root_path
  end

  test "child cannot update another child's sticker goal" do
    other_profile = child_profiles(:two)
    sign_in_as @child
    assert_no_changes -> { other_profile.reload.sticker_goal } do
      patch parent_child_child_profile_path(other_profile),
            params: { child_profile: { sticker_goal: 5 } }
    end

    assert_redirected_to root_path
  end

  test "settings page has a goal field that is blank by default" do
    sign_in_as @parent
    get edit_parent_child_path(@profile)

    assert_response :success
    assert_select "input[name='child_profile[goal]']"
  end

  test "parent can update default goal" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { goal: "New bike" } }

    assert_redirected_to edit_parent_child_path(@profile)
    assert_equal "New bike", @profile.reload.goal
  end

  test "updating default goal also updates active card goal when card is not overridden" do
    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { goal: "New bike" } }

    assert_equal "New bike", @profile.active_sticker_card.reload.goal
  end

  test "updating default goal does not update active card when card goal was overridden" do
    card = @profile.active_sticker_card
    card.update!(goal: "€2,50", goal_overridden: true)

    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { goal: "New bike" } }

    assert_equal "€2,50", card.reload.goal
  end

  test "child cannot update default goal" do
    sign_in_as @child
    assert_no_changes -> { @profile.reload.goal } do
      patch parent_child_child_profile_path(@profile),
            params: { child_profile: { goal: "Sneaky" } }
    end
    assert_redirected_to root_path
  end

  test "admin can update sticker_goal" do
    sign_in_as @admin
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { sticker_goal: 7 } }

    assert_redirected_to edit_parent_child_path(@profile)
    assert_equal 7, @profile.reload.sticker_goal
  end
end
