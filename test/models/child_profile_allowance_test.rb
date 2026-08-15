require "test_helper"

class ChildProfileAllowanceTest < ActiveSupport::TestCase
  def setup
    @profile = child_profiles(:two)
  end

  test "child profile can have allowances" do
    allowance = Allowance.create!(child_profile: @profile, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 5, next_due_on: Date.today)
    assert_includes @profile.allowances, allowance
  end

  test "destroying child profile destroys its allowances" do
    Allowance.create!(child_profile: @profile, kind: :zakgeld, amount_cents: 500,
                      frequency: :weekly, due_day: 5, next_due_on: Date.today)
    assert_difference -> { Allowance.count }, -1 do
      @profile.destroy
    end
  end

  test "zakgeld returns the zakgeld allowance" do
    allowance = Allowance.create!(child_profile: @profile, kind: :zakgeld, amount_cents: 500,
                                  frequency: :weekly, due_day: 5, next_due_on: Date.today)
    assert_equal allowance, @profile.zakgeld
  end

  test "zakgeld returns nil when not configured" do
    assert_nil @profile.zakgeld
  end

  test "kleedgeld returns the kleedgeld allowance" do
    allowance = Allowance.create!(child_profile: @profile, kind: :kleedgeld, amount_cents: 3000,
                                  frequency: :monthly, due_day: 1, next_due_on: Date.today)
    assert_equal allowance, @profile.kleedgeld
  end

  test "kleedgeld returns nil when not configured" do
    assert_nil @profile.kleedgeld
  end

  test "birthdate can be stored on child profile" do
    @profile.update!(birthdate: Date.new(2014, 3, 15))
    assert_equal Date.new(2014, 3, 15), @profile.reload.birthdate
  end

  test "birthdate is optional" do
    assert_nil @profile.birthdate
    assert @profile.valid?
  end
end
