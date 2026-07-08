require "test_helper"

class Parent::StickersTurboStreamTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @profile = child_profiles(:one)
    @card    = sticker_cards(:one)
  end

  test "turbo_stream request returns ok, not a redirect" do
    sign_in_as @parent

    post parent_child_sticker_path(@profile),
         params: { emoji_mode: "random" },
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
  end

  test "html request still redirects for non-JS fallback" do
    sign_in_as @parent

    post parent_child_sticker_path(@profile),
         params: { emoji_mode: "random" }

    assert_redirected_to parent_children_path
  end
end

class Parent::PenaltiesTurboStreamTest < ActionDispatch::IntegrationTest
  setup do
    @parent  = users(:parent)
    @profile = child_profiles(:one)
    @card    = sticker_cards(:one)
  end

  test "turbo_stream request returns ok, not a redirect" do
    sign_in_as @parent

    post parent_child_penalty_path(@profile),
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
  end

  test "html request still redirects for non-JS fallback" do
    sign_in_as @parent

    post parent_child_penalty_path(@profile)

    assert_redirected_to parent_children_path
  end
end

class Parent::RewardsTurboStreamTest < ActionDispatch::IntegrationTest
  setup do
    @parent       = users(:parent)
    @profile      = child_profiles(:two)
    @completed_card = sticker_cards(:completed_unrewarded)
  end

  test "turbo_stream request returns ok, not a redirect" do
    sign_in_as @parent

    post parent_child_reward_path(@profile),
         headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :ok
  end

  test "html request still redirects for non-JS fallback" do
    sign_in_as @parent

    post parent_child_reward_path(@profile)

    assert_redirected_to parent_children_path
  end
end
