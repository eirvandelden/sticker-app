require "test_helper"

class Users::ProfilesAvatarTest < ActionDispatch::IntegrationTest
  setup do
    @child  = users(:user)
    @parent = users(:parent)
  end

  test "child can view their own profile" do
    sign_in_as @child
    get user_profile_path(@child)

    assert_response :success
  end

  test "child cannot view another user's profile" do
    sign_in_as @child
    get user_profile_path(@parent)

    assert_redirected_to root_path
  end

  test "parent can view another user's profile" do
    sign_in_as @parent
    get user_profile_path(@child)

    assert_response :success
  end

  test "child can reach profile edit page" do
    sign_in_as @child
    get edit_user_profile_path(@child)

    assert_response :success
    assert_select "form"
  end

  test "child can upload their own avatar" do
    sign_in_as @child
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch user_profile_path(@child), params: { user: { avatar: avatar } }

    assert_redirected_to user_profile_path(@child)
    assert_predicate @child.reload.avatar, :attached?
  end

  test "child cannot change their name via profile" do
    sign_in_as @child
    original_name = @child.name
    patch user_profile_path(@child), params: { user: { name: "Hacked Name", avatar: fixture_file_upload("avatar.png", "image/png") } }

    assert_equal original_name, @child.reload.name
  end

  test "parent can upload their own avatar" do
    sign_in_as @parent
    avatar = fixture_file_upload("avatar.png", "image/png")
    patch user_profile_path(@parent), params: { user: { avatar: avatar } }

    assert_redirected_to user_profile_path(@parent)
    assert_predicate @parent.reload.avatar, :attached?
  end

  test "parent cannot upload a non-image avatar" do
    sign_in_as @parent
    avatar = fixture_file_upload("avatar.txt", "text/plain")
    patch user_profile_path(@parent), params: { user: { avatar: avatar } }

    assert_response :unprocessable_entity
    assert_not_predicate @parent.reload.avatar, :attached?
  end

  test "child cannot edit another user's profile" do
    sign_in_as @child
    get edit_user_profile_path(@parent)

    assert_redirected_to root_path
  end

  test "blank password does not change the parent's password" do
    sign_in_as @parent
    original_digest = @parent.password_digest

    patch user_profile_path(@parent), params: { user: { name: @parent.name, password: "" } }

    assert_redirected_to user_profile_path(@parent)
    assert_equal original_digest, @parent.reload.password_digest
  end

  test "non-blank password updates the parent's password" do
    sign_in_as @parent

    patch user_profile_path(@parent), params: { user: { name: @parent.name, password: "new-secure-pass" } }

    assert_redirected_to user_profile_path(@parent)
    assert @parent.reload.authenticate("new-secure-pass"), "Expected password to be updated"
  end
end
