require "test_helper"

class UserNameTest < ActiveSupport::TestCase
  test "user is invalid without a name" do
    user = users(:parent)
    user.name = nil
    assert_not user.valid?
    assert_includes user.errors[:name], "can't be blank"
  end

  test "user is valid with a name" do
    user = users(:parent)
    assert_predicate user, :valid?
  end
end
