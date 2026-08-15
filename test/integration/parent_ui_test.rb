require "test_helper"

class ParentUiTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @profile = child_profiles(:one)
  end

  test "parent logs in and sees sticker and penalty buttons" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "form[action=?]", parent_child_sticker_path(child_id: @profile)
    assert_select "form[action=?]", parent_child_penalty_path(child_id: @profile)
  end

  test "parent sees reward button after completed card starts next card" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    # profile_two has a completed_unrewarded card — reward button should appear
    assert_select "form[action=?]", parent_child_reward_path(child_id: child_profiles(:two))
  end

  test "parent dashboard shows a progress bar for each child card" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "article progress", minimum: 1
    assert_select "article progress[aria-label=?]", I18n.t("parent.dashboard.progress", current: 0, total: 2)
  end

  test "parent dashboard wraps sticker and penalty buttons in semantic footer" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "article > footer" do
      assert_select "form", minimum: 2
    end
    assert_select ".child-actions", count: 0
  end

  test "parent dashboard has a single main landmark" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "main", count: 1
  end

  test "parent dashboard shows card goal as read-only text" do
    sign_in_as @parent
    get parent_children_path

    assert_response :success
    assert_select "##{dom_id(@profile, :parent_card)}" do
      assert_select "p", text: /New bike/
    end
  end

  test "parent dashboard shows inline override form for card goal" do
    sign_in_as @parent
    get parent_children_path

    assert_response :success
    assert_select "form[action='#{parent_child_card_goal_path(@profile)}']" do
      assert_select "input[name='sticker_card[goal]']"
    end
  end

  test "parent dashboard shows nothing for goal when card goal is blank" do
    sticker_cards(:one).update_column(:goal, nil)

    sign_in_as @parent
    get parent_children_path

    assert_response :success
    assert_select "##{dom_id(@profile, :parent_card)} p", text: /Saving for/, count: 0
  end
end
