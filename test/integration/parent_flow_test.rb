require "test_helper"

class ParentFlowTest < ActionDispatch::IntegrationTest
  setup do
    @parent          = users(:parent)
    @profile_one     = child_profiles(:one)
    @profile_two     = child_profiles(:two)
    @profile_three   = child_profiles(:three)
    @card_one        = sticker_cards(:one)
    @card_three      = sticker_cards(:three)
    @completed_card  = sticker_cards(:completed_unrewarded)
  end

  # Scenario 6: Parent views children list
  test "parent views list of children" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
  end

  # Scenario 7: Parent awards a positive sticker
  test "parent awards a positive sticker and count increases" do
    sign_in_as @parent
    assert_difference -> { @card_one.stickers.where(kind: :positive).count }, +1 do
      post parent_child_sticker_path(child_id: @profile_one),
           params: { emoji_mode: "random" }
    end
    assert_redirected_to parent_children_path
  end

  # Scenario 8: Parent awards a penalty
  test "parent awards a penalty and negative sticker count increases" do
    sign_in_as @parent
    assert_difference -> { @card_one.stickers.where(kind: :negative).count }, +1 do
      post parent_child_penalty_path(child_id: @profile_one)
    end
    assert_redirected_to parent_children_path
  end

  # Scenario 9: Card auto-completes when goal is reached
  test "sticker card completes when positive stickers reach goal" do
    sign_in_as @parent
    # card_three has 2 positive stickers, goal is 3 — one more completes it
    post parent_child_sticker_path(child_id: @profile_three),
         params: { emoji_mode: "random" }
    assert @card_three.reload.completed?, "Expected card to be marked completed"
    assert_not_nil @card_three.reload.completed_at
  end

  # Scenario 10: New card auto-created after completion
  test "new sticker card is auto-created when previous card completes" do
    sign_in_as @parent
    assert_difference -> { @profile_three.sticker_cards.count }, +1 do
      post parent_child_sticker_path(child_id: @profile_three),
           params: { emoji_mode: "random" }
    end
  end

  # Scenario 11: Parent marks reward as given on completed card
  test "parent marks completed card reward as given" do
    sign_in_as @parent
    post parent_child_reward_path(child_id: @profile_two)
    assert_redirected_to parent_children_path
    assert @completed_card.reload.reward_given?,
           "Expected reward_given to be true after marking reward"
  end

  # Scenario 12: Parent views sticker history
  test "parent views sticker history for a child" do
    sign_in_as @parent
    get parent_child_history_path(child_id: @profile_one)
    assert_response :success
  end
end

class AdminNavTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @parent = users(:parent)
  end

  test "admin sees admin navigation link on parent dashboard" do
    sign_in_as @admin
    get parent_children_path
    assert_response :success
    assert_select "a[href='#{admin_root_path}']"
  end

  test "parent does not see admin navigation link" do
    sign_in_as @parent
    get parent_children_path
    assert_response :success
    assert_select "a[href='#{admin_root_path}']", count: 0
  end
end

class ParentHappyFlowTest < ActionDispatch::IntegrationTest
  setup do
    @parent   = users(:parent)
    @profile  = child_profiles(:one)
    @card     = sticker_cards(:one)
  end

  test "parent logs in, sees children, gives sticker and penalty" do
    sign_in_as @parent
    assert_response :success

    assert_select "article h2", minimum: 1

    assert_difference -> { @card.stickers.where(kind: :positive).count }, +1 do
      post parent_child_sticker_path(@profile), params: { emoji_mode: "random" }
    end
    assert_redirected_to parent_children_path

    assert_difference -> { @card.stickers.where(kind: :negative).count }, +1 do
      post parent_child_penalty_path(@profile)
    end
    assert_redirected_to parent_children_path
  end
end

class AdminParentFlowTest < ActionDispatch::IntegrationTest
  setup do
    @admin   = users(:admin)
    @profile = child_profiles(:one)
    @card    = sticker_cards(:one)
  end

  test "admin logs in, sees parent dashboard, gives sticker and penalty" do
    sign_in_as @admin
    assert_response :success
    assert_select "a[href='#{admin_root_path}']"
    assert_select "article h2", minimum: 1

    assert_difference -> { @card.stickers.where(kind: :positive).count }, +1 do
      post parent_child_sticker_path(@profile), params: { emoji_mode: "random" }
    end
    assert_redirected_to parent_children_path

    assert_difference -> { @card.stickers.where(kind: :negative).count }, +1 do
      post parent_child_penalty_path(@profile)
    end
    assert_redirected_to parent_children_path
  end
end
