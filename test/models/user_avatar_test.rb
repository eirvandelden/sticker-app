require "test_helper"

class UserAvatarTest < ActiveSupport::TestCase
  test "user is invalid with a spoofed image content type" do
    user = users(:parent)
    user.avatar.attach(
      io: StringIO.new("not an image"),
      filename: "avatar.png",
      content_type: "image/png"
    )

    assert_not user.valid?
    assert_includes user.errors.details[:avatar].pluck(:error), :invalid_content_type
  end

  test "user is invalid with an oversized avatar" do
    user = users(:parent)
    user.avatar.attach(
      io: StringIO.new("x" * 6.megabytes),
      filename: "avatar.png",
      content_type: "image/png"
    )

    assert_not user.valid?
    assert_includes user.errors.details[:avatar].pluck(:error), :file_size_too_large
  end
end
