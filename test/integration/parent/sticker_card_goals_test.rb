require "test_helper"

class Parent::StickerCardGoalsTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @child   = users(:user)
    @profile = child_profiles(:one)
    @card    = sticker_cards(:one)
  end

  test "parent can override the current card's goal" do
    sign_in_as @parent
    patch parent_child_card_goal_path(@profile),
          params: { sticker_card: { goal: "€2,50" } }

    assert_redirected_to parent_children_path
    assert_equal "€2,50", @card.reload.goal
    assert @card.reload.goal_overridden
  end

  test "overriding card goal does not change default goal on child profile" do
    original_goal = @profile.goal

    sign_in_as @parent
    patch parent_child_card_goal_path(@profile),
          params: { sticker_card: { goal: "€2,50" } }

    assert_equal original_goal, @profile.reload.goal
  end

  test "after card goal is overridden, updating default goal does not touch the card" do
    @card.update!(goal: "€2,50", goal_overridden: true)

    sign_in_as @parent
    patch parent_child_child_profile_path(@profile),
          params: { child_profile: { goal: "New bike" } }

    assert_equal "€2,50", @card.reload.goal
  end

  test "child cannot override card goal" do
    sign_in_as @child
    assert_no_changes -> { @card.reload.goal } do
      patch parent_child_card_goal_path(@profile),
            params: { sticker_card: { goal: "Sneaky" } }
    end
    assert_redirected_to root_path
  end
end
